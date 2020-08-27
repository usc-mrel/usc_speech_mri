import numpy as np
from scipy.ndimage.morphology import binary_dilation
from scipy.signal import convolve2d
# import sigpy as sp

import sigpy.plot as pl


# ##############################################################################
# TODO: enable the below computations on GPUs... needs to replace scipy.signal.convolve2D with sp.convolve and so on
# ##############################################################################

def estimate_coilmap_walsh(img, smoothing=5, thresh=0):
    """Estimates relative coil sensitivity maps from a set of coil images
    using the eigen-vector method described by Walsh et al. (Magn Reson Med 2000;43:682-90)

    :param img: (complex array), size: [n_ch, n_y, n_x]
    :param smoothing: (int) smoothing factor
    :param thresh: (float) thresholding factor
    :return: (complex array), size: [n_ch, n_y, n_x], multi-channel coil sensitivity maps

    Code is based on a Matlab implementation by Michael S. Hansen
    made available for the ISMRM 2013 Sunrise Educational Course

    Implemented by Yongwan Lim (yongwanl@usc.edu) Feb. 2020
    """

    # (n_ch, n_y, n_x) = img.shape

    eps = np.finfo(np.float64).eps

    mag = compute_rss(img, eps=0, dim=0)

    # pl.ImagePlot(np.squeeze(mag), title='mag')

    h_smooth = np.ones((smoothing, smoothing))/(smoothing**2)
    mag_smooth = convolve2d(mag, h_smooth, mode='same')

    mask = mag_smooth > thresh*np.max(mag_smooth)
    mask = binary_dilation(mask, iterations=4)

    s_raw = img / (np.expand_dims(mag, axis=0) + eps)
    s_raw = s_raw * np.expand_dims(mask, axis=0)

    # pl.ImagePlot(np.squeeze(s_raw), z=0, title='s_raw')

    r_s = compute_correlation_matrix(s_raw)
    r_s_cov = np.zeros(r_s.shape, dtype=np.complex64)

    if smoothing > 1:
        for i in range(r_s.shape[0]):
            for j in range(r_s.shape[1]):
                r_s_cov[i, j, :, :] = convolve2d(r_s[i, j, :, :], h_smooth, mode='same').reshape(1, 1, r_s.shape[2], r_s.shape[3])

    return compute_eig_power(r_s_cov, eps)


def compute_correlation_matrix(s_raw):
    """unction correlation_matrix calculates the sample correlation matrix (Rs) for
    each pixel of a multi-coil image s(coil, y, x)

    :param s_raw: (complex array), size: [n_ch, n_y, n_x], complex multi-coil image s(coil,y,x)
    :return r_s: (complex array), size: [n_ch, n_ch, n_y, n_x], complex sample correlation matrices

    Code is based on an original Matlab implementation by Peter Kellman, NHLBI
    Implemented by Yongwan Lim (yongwanl@usc.edu) Feb. 2020

    """

    (n_ch, n_y, n_x) = s_raw.shape

    r_s = np.zeros((n_ch, n_ch, n_y, n_x), dtype=np.complex64)

    for i in range(n_ch):
        for j in range(i):
            r_s[i, j, :, :] = s_raw[i, :, :] * np.conj(s_raw[j, :, :])
            r_s[j, i, :, :] = np.conj(r_s[i, j, :, :])

        r_s[i, i, :, :] = s_raw[i, :, :] * np.conj(s_raw[i, :, :])

    return r_s


def compute_eig_power(r_s, eps, n_iter=2):
    """ Vectorized method for calculating the dominant eigenvector based on
    power method. Input, R, is an image of sample correlation matrices
    where: R[:,:,y,x] are sample correlation matrices (ncoil x ncoil) for each pixel

    :param r_s: (complex array) size: [n_ch, n_y, n_x],
    :param eps: (float) epsilon
    :param n_iter: (int) number of iterations
    :return v: (complex array_, size: [n_ch, n_y, n_x], the dominant eigenvector

    Code is based on an original Matlab implementation by Peter Kellman, NHLBI
    Implemented by Yongwan Lim (yongwanl@usc.edu) Feb. 2020

    """

    (n_ch, _, n_y, n_x) = r_s.shape

    v = np.ones((n_ch, n_y, n_x), dtype=np.complex64)

    # d = np.zeros((n_y, n_x))

    for i in range(n_iter):
        v = np.sum(r_s * np.expand_dims(v, axis=1).repeat(n_ch, axis=1), axis=0)
        d = compute_rss(v, eps)
        v = v / np.expand_dims(d, axis=0)

    phase = np.expand_dims(np.angle(np.conj(v[0, :, :])), axis=0)

    v = v * np.exp(1j*phase)

    return np.conj(v)


def compute_rss(v, eps, dim=0):
    """Computes root-sum-of-squares along a single dimension.

    :param v: multi-dimensional array of samples
    :param eps: (float) epsilon
    :param dim: (int), dimension of reduction; defaults to last dimension
    :return: root sum of squares result

    Implemented by Yongwan Lim (yongwanl@usc.edu) Feb. 2020
    """
    res = np.sum(np.real(v)**2 + np.imag(v)**2, axis=dim) ** 0.5

    res[res <= eps] = eps
    # pl.ImagePlot(np.squeeze(res), title='res')
    return res




