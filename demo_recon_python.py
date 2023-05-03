"""
Python implementation for parallel imaging and compressed sensing MRI image reconstruction with temporal finite difference constraint

Use example
python demo_recon_python.py --path_to_data data/ --filename sub001/2drt/raw/sub001_2drt_vcv1_r1_raw.h5 --n_arms 2 --n_recon_frames 0 --reg_lambda 0.08 --max_iter 100 --cuda --gpu_id 0

Implemented by Yongwan Lim (yongwanl@usc.edu) Feb. 2020
"""

import os
import argparse

import ismrmrd.xsd
# import numpy as np
# import cupy as cp
import sigpy as sp
from cs_recon_python.plot_mri import img_play
from cs_recon_python.recon import TotalVariationRecon, TotalVariationReconNLCG
from cs_recon_python.util import estimate_coilmap_walsh
import h5py

parser = argparse.ArgumentParser(description='Python PICS with temporal FD constrained reconstruction')

parser.add_argument('--path_to_data', type=str, default='dataset/', help='path to data')
parser.add_argument('--filename', type=str, default='sub001/2drt/raw/sub001_2drt_vcv1_r1_raw.h5', help='filename')

parser.add_argument('--n_arms', type=int, default=2, help='Number of spiral arms to use to reconstruct per frame')
parser.add_argument('--n_recon_frames', type=int, default=50,
                    help='Number of frames you want to reconstruct. If 0, reconstruct maximum number of frames')

parser.add_argument('--n_full_arms', type=int, default=13, help='Number of fully sampled spirals')

parser.add_argument('--reg_lambda', type=float, default=0.08, help='temporal FD regularization parameter')
parser.add_argument('--max_iter', type=int, default=100, help='maximum iteration for recon')

parser.add_argument('--cuda', action='store_true', help='use cuda?')
parser.add_argument('--gpu_id', type=int, default=0, help='gpu id, only being seen if --cuda')
parser.add_argument('--tr', type=float, default=6.004e-3, help='Repetition time (TR), will be used to generate video')

parser.add_argument('--methods', type=str, default='nlcg', help='recon methos: nlcg or pdhg')
opt = parser.parse_args()

import time

start = time.time()

# path_to_data = 'ismrmrd_data/Spiral/'
# filename = 'spiral'

if opt.cuda:
    device_id = opt.gpu_id
else:
    device_id = -1

device = sp.Device(device_id)
xp = device.xp

with device:
# Load parameters from opt
    n_full_arms = opt.n_full_arms                       # number of fully sampled spirals
    n_arms = opt.n_arms                                 # number of spiral arms to use per frame
    reg_lambda = opt.reg_lambda
    max_iter = opt.max_iter
    filename = opt.filename
    path_to_data = opt.path_to_data


################################################################################
# Load Data
#

    print('Loading data...', end='', flush=True)

    filename = filename.strip('.h5')

    # Load file
    filename = os.path.join(path_to_data, '%s.h5' % filename)
    if not os.path.isfile(filename):
        print("%s is not a valid file" % filename)
        raise SystemExit


    dset = ismrmrd.Dataset(filename, 'dataset', create_if_needed=False)

    header = ismrmrd.xsd.CreateFromDocument(dset.read_xml_header())
    enc = header.encoding[0]

    acq_header = dset.read_acquisition(0).getHead()
    nk = acq_header.number_of_samples                               # number of samples per spiral
    nc = header.acquisitionSystemInformation.receiverChannels       # number of coils
    ns = dset.number_of_acquisitions()                              # number of spirals

    # Matrix size
    eNx = enc.encodedSpace.matrixSize.x
    eNy = enc.encodedSpace.matrixSize.y
    eNz = enc.encodedSpace.matrixSize.z
    rNx = enc.reconSpace.matrixSize.x
    rNy = enc.reconSpace.matrixSize.y
    rNz = enc.reconSpace.matrixSize.z

    # Field of View
    eFOVx = enc.encodedSpace.fieldOfView_mm.x
    eFOVy = enc.encodedSpace.fieldOfView_mm.y
    eFOVz = enc.encodedSpace.fieldOfView_mm.z
    rFOVx = enc.reconSpace.fieldOfView_mm.x
    rFOVy = enc.reconSpace.fieldOfView_mm.y
    rFOVz = enc.reconSpace.fieldOfView_mm.z

    # Initialize a storage array
    kdata = xp.zeros((ns, nc, nk), dtype=xp.complex64)
    kloc = xp.zeros((ns, nk, 2), dtype=xp.float32)
    kweight = xp.zeros((nk, 1), dtype=xp.float32)
    spokeindex = xp.zeros((ns,), dtype=xp.uint32)

    # Loop through the rest of the acquisitions and stuff
    for acqnum in range(dset.number_of_acquisitions()):
        acq = dset.read_acquisition(acqnum)

        # Stuff into the buffer
        kdata[acqnum, :, :] = xp.array(acq.data)
        kloc[acqnum, :, :] = xp.array(acq.traj[:, :2])
        spokeindex[acqnum] = acq.idx.kspace_encode_step_1

        if acqnum == 0:
            kweight = xp.array(acq.traj[:, 2])

    # TODO:
    # this number 1.4790e3 may be just an arbitrary number
    # and the scaling/normalization may need to be determined.
    kdata = 1.4790e3*kdata/xp.max(kdata)

    # the range of kloc should be between -N/2 and N/2
    # Note: xp.max(xp.sum(kloc**2, axis=2) ** 0.5) is 0.5 but xp.max(kloc) is < 0.5
    #       We may need to scale the kloc based on xp.max(kloc)

    kloc = kloc / xp.max(kloc) * 0.5 * xp.ushort(rNy)
    # kloc = kloc*rNy
    # print(xp.max(kloc))

    # number of time frames possible to recon
    n_total_frames = int(xp.floor(ns/n_arms))

    assert opt.n_recon_frames <= n_total_frames, \
        'n_recon_frames exceeds the total number of frames possible to recon. Please set -n_recon_frames smaller'

    # if this is set to 0, then reconstruct the entire data
    if opt.n_recon_frames == 0:
        n_recon_frames = n_total_frames
    # this option is for fast debugging, but make sure recon quality can be depending on the number of frames
    else:
        n_recon_frames = opt.n_recon_frames

    print('Done!')


################################################################################
# Estimate coil maps using Walsh's method from temporal averaged data
#
with device:

    # assume spiral sampling patterns repeat every n_full_arms
    n_avr = int(xp.floor(ns/n_full_arms))

    kdata_avr = kdata[:n_avr*n_full_arms, :, :].reshape(n_avr, n_full_arms, nc, nk)
    kdata_avr = xp.mean(kdata_avr, axis=0)
    kdata_avr = xp.transpose(kdata_avr, (1, 0, 2))

    kloc_avr = kloc[:n_full_arms, :, :]

    avr_img = sp.nufft_adjoint(kdata_avr*kweight[xp.newaxis, xp.newaxis, :], kloc_avr)

    # needs to process on CPUs
    sens_map = estimate_coilmap_walsh(sp.to_device(avr_img, -1), smoothing=20, thresh=0.0)

    # copy it to GPU
    sens_map = sp.to_device(sens_map, device_id)
    # pl.ImagePlot(xp.squeeze(avr_img), z=0, title='Multi-channel Time Averaged Image')
    # pl.ImagePlot(xp.squeeze(xp.abs(sens_map)), z=0, title='Walsh (Python)')

    # TODO Espirit coil map estimation needs to be improved


################################################################################
# Reshape Data
#
with device:

    # crop kdata to keep only the first (n_frames*n_arms) data
    kdata = kdata[:n_recon_frames*n_arms, :, :]
    kdata = kdata.reshape(n_recon_frames, n_arms, nc, nk)            # [n_recon_frames, n_arms, n_ch, n_samples]
    kdata = xp.transpose(kdata, (0, 2, 1, 3))                           # [n_recon_frames, n_ch, n_arms, n_samples]

    kweight = xp.expand_dims(kweight, axis=0)                             # [1, n_samples]

    kloc = kloc[:n_recon_frames*n_arms, :, :]
    kloc = kloc.reshape(n_recon_frames, n_arms, nk, -1)                # [n_recon_frames, n_arms, n_samples, 2]

    print('kdata array shape: {}'.format(kdata.shape))
    print('kweight array shape: {}'.format(kweight.shape))
    print('kloc array shape: {}'.format(kloc.shape))


################################################################################
# Gridding Example for one frame
#
with device:

    zero_filed_img = sp.nufft_adjoint(kdata[0, :, :, :] * kweight, kloc[0, :, :, :], (nc, rNy, rNx))
    # pl.ImagePlot(xp.squeeze(zero_filed_img), z=0, title='Multi-channel Gridding')


################################################################################
# CS Reconstruction
#

    reg_lambda_scaled = reg_lambda * xp.max(xp.abs(zero_filed_img))
    if opt.methods == "nlcg": # non-linear conjugate gradient
        img, fnorm, tnorm, cost = TotalVariationReconNLCG(kdata, kweight, kloc, sens_map, reg_lambda_scaled, max_iter).run()
    elif opt.methods == "pdhg": # primal dual hybrid gradient
        img = TotalVariationRecon(kdata, kweight, kloc, sens_map, reg_lambda=reg_lambda_scaled, dim_fd=(0,), max_iter=max_iter, device=device).run()

################################################################################
# Save video
#

img_cpu = sp.to_device(img,-1)

(f_dir, f_basename) = os.path.split(filename)
f_basename = 'recon_' + f_basename.strip(".h5") + '_'
f_param = 'narms{}_nt{}_l1{}_niter{}_{}_gpuid{}'.format(n_arms, n_recon_frames, reg_lambda, max_iter, opt.methods, device_id)
f_name = os.path.join(f_dir, f_basename+f_param)

# TODO Save reconstruction in some accessable file format

end = time.time()
comp_time = end -start
print(end - start)

h5 = h5py.File(f_name + '.h5', 'w')
h5.create_dataset('image', data=img_cpu)
#h5.create_dataset('cost', data=cost)
#h5.create_dataset('tnorm', data=tnorm)
#h5.create_dataset('fnorm', data=fnorm)
#h5.create_dataset('lambda_t', data=reg_lambda_scaled)
h5.create_dataset('comp_time', data=comp_time)
h5.close()

ani2 = img_play(img_cpu, opt.tr*1000*n_arms, name=f_name)

