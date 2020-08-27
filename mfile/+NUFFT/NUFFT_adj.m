function image = NUFFT_adj(kSpace_non_cart, N)
%--------------------------------------------------------------------------
%   [image] = NUFFT_adj(kSpace_non_cart,N)
%--------------------------------------------------------------------------
%   Interpolate non-Cartesian k-space on a Cartesian grid, then perform FFT
%--------------------------------------------------------------------------
%   Inputs:
%       - kSpace_non_cart   [nsamples, nrep, nof, ...]
%       - N                 [structure]
%
%           'nsamples'  number of samples per readout (a radial ray or
%                       spiral arm)
%           'nrep'      number of repetetions per time frame (number of 
%                       radial rays or spiral arms)
%           'nof'       number of time frames
%
%       - kSpace_non_cart   non-Cartesian k-space data
%       - N                 see 'help NUFFT.init.m'
%--------------------------------------------------------------------------
%   Output:
%       - image             [sx, sx, nof, ...]
%                           inverse NUFFT result (not nessessary an image)
%--------------------------------------------------------------------------
%   Reference:
%       [1] Nonuniform Fast Fourier Transforms Using Min-Max Interpolation.
%           IEEE T-SP, 2003, 51(2):560-74. 
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

kSpace_non_cart = bsxfun(@times,N.W,kSpace_non_cart); % density compensation

kSpace_cart = NUFFT.ncart2cart(kSpace_non_cart,N);

image = ifft2(kSpace_cart);

sx = N.size_image(1);

if N.sx_over >= N.size_image(1)
    image = image(1:sx,1:sx,:,:,:,:);
else
    image = fftshift2(image);
end

image = bsxfun(@times,image,N.Apodizer);