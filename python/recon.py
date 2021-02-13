# import numpy as np
# import cupy as cp

import sigpy as sp
from sigpy import util

class TotalVariationRecon(sp.app.LinearLeastSquares):
    r"""Total variation regularized reconstruction.

     Considers the problem:

     .. math::
         \min_x \frac{1}{2} \| P F S x - y \|_2^2 + \lambda \| G_t x \|_1

     where P is the sampling operator, F is the Non uniform Fourier transform operator,
     S is the SENSE operator, G is the gradient operator,
     x is the image, and y is the k-space measurements.

     Args:
         ksp (array): k-space measurements.
         dcf (float or array): weights for non-Cartesian Sampling.
         traj (None or array): coordinates.
         mps (array): sensitivity maps.
         reg_lambda (float): temporal TV regularization parameter.

         device (Device): device to perform reconstruction.
         # coil_batch_size (int): batch size to process coils.
         Only affects memory usage.
         comm (Communicator): communicator for distributed computing.
         **kwargs: Other optional arguments.

     References:
         Block, K. T., Uecker, M., & Frahm, J. (2007).
         Undersampled radial MRI with multiple coils.
         Iterative image reconstruction using a total variation constraint.
         Magnetic Resonance in Medicine, 57(6), 1086-1098.

    Modified from TotalVariationRecon in Sigpy package to apply TV along time dimension
    Implemented by Yongwan Lim (yongwanl@usc.edu) Feb. 2020
    """

    def __init__(self, ksp, dcf, traj, mps, reg_lambda, dim_fd=(0,),
                 device=sp.cpu_device, comm=None, show_pbar=True, **kwargs):

        ksp = sp.to_device(ksp * (dcf**0.5), device=device)

        (n_ch, n_y, n_x) = mps.shape

        S = sp.linop.Multiply((1, n_y, n_x), mps)
        R = sp.linop.Reshape([1] + list(ksp.shape[1:]), ksp.shape[1:])

        T = []
        for ksp_each, traj_each in zip(ksp, traj):
            F = sp.linop.NUFFT((n_ch, n_x, n_y), traj_each)
            P = sp.linop.Multiply(ksp_each.shape, dcf**0.5)

            T.append(R * P * F * S)

        A = sp.linop.Diag(T, iaxis=0, oaxis=0)
        G = sp.linop.FiniteDifference(A.ishape, axes=dim_fd)
        proxg = sp.prox.L1Reg(G.oshape, reg_lambda)

        def g(x):
            device = sp.get_device(x)
            xp = device.xp
            with device:
                # TODO: can it be numerically beneficial to add the eps?
                return reg_lambda * xp.sum(xp.sqrt(xp.abs(x)**2 + xp.finfo(float).eps)).item()

        if comm is not None:
            show_pbar = show_pbar and comm.rank == 0

        super().__init__(A, ksp, proxg=proxg, g=g, G=G, show_pbar=show_pbar, **kwargs)


class TotalVariationReconNLCG:
    """constrained reconstruction of the problem:
    min_x ||Ax-y||_2^2 + lambda_t*||delta_t x||_1

    :param kdata: k-space data
    :param kweight: density compensation function
    :param kloc: k-space trajectory
    :param sens_map: sensitivity map
    :param lambda_t: regularization parameter
    :param max_iter: maxmium iteration number
    :return: img: reconstructed image
    """

    def __init__(self, ksp, dcf, traj, mps, lambda_t, max_iter, step_size=2, device=sp.cpu_device):

        ksp = sp.to_device(ksp * (dcf ** 0.5), device=device)
        (n_ch, n_y, n_x) = mps.shape

        S = sp.linop.Multiply((1, n_y, n_x), mps)
        R = sp.linop.Reshape([1] + list(ksp.shape[1:]), ksp.shape[1:])

        T = []
        for ksp_each, traj_each in zip(ksp, traj):
            F = sp.linop.NUFFT((n_ch, n_x, n_y), traj_each)
            P = sp.linop.Multiply(ksp_each.shape, dcf ** 0.5)

            T.append(R * P * F * S)

        A = sp.linop.Diag(T, iaxis=0, oaxis=0)
        G = sp.linop.FiniteDifference(A.ishape, axes=(0,))

        self.device = device

        self.A = A
        self.y = ksp
        self.G = G
        with self.device:
            self.x = self.A.H(ksp)

        self.init_step_size = step_size
        self.max_iter = max_iter
        self.lambda_t = lambda_t

    def _update_fidelity(self, img):
        with self.device:
            r = self.y - self.A(img)
            return self.A.H(r)

    def _update_temporal_fd(self, img):
        with self.device:
            xp = self.device.xp
            temp_a = xp.diff(img, n=1, axis=0)
            temp_a = temp_a / xp.sqrt(abs(temp_a) ** 2 + xp.finfo(float).eps)
            temp_b = xp.diff(temp_a, n=1, axis=0)
            ttv_update = xp.zeros(img.shape, dtype=xp.complex64)
            ttv_update[0, :, :] = temp_a[0, :, :]
            ttv_update[1:-1, :, :] = temp_b
            ttv_update[-1, :, :] = -temp_a[-1, :, :]

            return ttv_update
            # return self.G.H(self.G(img))

    def _calculate_fnorm(self, img):
        with self.device:
            xp = self.device.xp
            r = self.y - self.A(img)
            return xp.real(xp.vdot(r, r)) / img.size

    def _calculate_tnorm(self, img):
        with self.device:
            xp = self.device.xp
            dtimg = xp.diff(img, n=1, axis=0)
            return self.lambda_t * xp.sum(xp.abs(dtimg)) / img.size
            # return self.lambda_t * xp.sum(xp.abs(self.G(img))) / img.size

    def run(self):
        with self.device:
            xp = self.device.xp
            img = self.x
            step_size = self.init_step_size

            fnorm = []
            tnorm = []
            cost = []
            for iter in range(self.max_iter):
                # calculate gradient of fidelity and regularization
                f_new = self._update_fidelity(img)
                util.axpy(f_new, self.lambda_t, xp.squeeze(self._update_temporal_fd(img)))

                f2_new = xp.vdot(f_new, f_new)

                if iter == 0:
                    f2_old = f2_new
                    f_old = f_new

                # conjugate gradient
                beta = f2_new / (f2_old + xp.finfo(float).eps)
                util.axpy(f_new, beta, f_old)
                f2_old = f2_new
                f_old = f_new

                # update image
                fnorm_t = self._calculate_fnorm(img)
                tnorm_t = self._calculate_tnorm(img)
                cost_t = fnorm_t+tnorm_t

                step_size = self._line_search(img, f_new, cost_t, step_size)
                util.axpy(img, step_size, f_old)

                #  TODO stop criteria
                # if abs(np.vdot(update_old.flatten(), update_old.flatten())) * step_size < 1e-6:
                #    break
                if step_size < 2e-3:
                    break

                fnorm.append(fnorm_t)
                tnorm.append(tnorm_t)
                cost.append(cost_t)

                print("Iter[%d/%d]\tStep:%.5f\tCost:%.3f" % (iter+1, self.max_iter, step_size, cost_t))

            return img, fnorm, tnorm, cost

    def _line_search(self, img, f_new, cost_old, step_size, max_iter=15, a=1.3, b=0.8):
        with self.device:
            flag = False

            for i in range(max_iter):
                img_new = img + step_size * f_new
                fnorm = self._calculate_fnorm(img_new)
                tnorm = self._calculate_tnorm(img_new)
                cost_new = fnorm + tnorm

                if cost_new > cost_old and flag is False:
                    step_size = step_size * b
                elif cost_new < cost_old:
                    step_size = step_size * a
                    cost_old = cost_new
                    flag = True
                elif cost_new > cost_old and flag is True:
                    step_size = step_size / a
                    break

            return step_size
