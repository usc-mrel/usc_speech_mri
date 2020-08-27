function kSpace_non_cart = NUFFT(image,N)
%--------------------------------------------------------------------------
%   [image] = NUFFT_adj(kSpace_non_cart,N)
%--------------------------------------------------------------------------
%   Perform 2D FFT on an image, then interpolate k-space on non-Cartesian
%   coordinates
%--------------------------------------------------------------------------
%   Inputs:
%       - image             [sx, sx, nof, ...]
%       - N                 [structure]
%
%           'sx'    input array size
%           'nof'   number of time frames
%
%       - image             input Cartesian array
%       - N                 see 'help NUFFT.init.m'
%--------------------------------------------------------------------------
%   Output:
%       - kSpace_non_cart   [nsamples, nrep, nof, ...]
%                           non-Cartesian k-space data
%
%           'nsamples'  number of samples per readout (a radial ray or
%                       spiral arm)
%           'nrep'      number of repetetions per time frame (number of 
%                       radial rays or spiral arms)
%--------------------------------------------------------------------------
%   Reference:
%       [1] Nonuniform Fast Fourier Transforms Using Min-Max Interpolation.
%           IEEE T-SP, 2003, 51(2):560-74. 
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

sx_over = N.sx_over;

image = bsxfun(@times, image, N.Apodizer);

if N.sx_over < N.size_image(1)
    image = fftshift2(image);
end
kSpace_cart = fft2(image,sx_over,sx_over);

kSpace_non_cart = NUFFT.cart2rad(kSpace_cart,N);