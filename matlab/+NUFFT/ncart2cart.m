function kSpace_cart = ncart2cart(kSpace_radial, N)
%--------------------------------------------------------------------------
%   [kSpace_cart] = ncart2cart(kSpace_cart, N)
%--------------------------------------------------------------------------
%   Interpolate non-Cartesian k-space on a Cartesian grid
%--------------------------------------------------------------------------
%   Inputs:
%       - kSpace_radial     [nsamples, nrep, nof, ...]
%       - N                 [structure]
%
%           'nsamples'  number of samples per readout (a radial ray or
%                       spiral arm)
%           'nrep'      number of repetetions per time frame (number of 
%                       radial rays or spiral arms)
%           'nof'       number of time frames
%
%       - kSpace_radial     non-Cartesian k-space data
%       - N                 see 'help NUFFT.init.m'
%--------------------------------------------------------------------------
%   Output:
%       - kSpace_cart       [sx, sx, nof, ...]
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
sx = size(kSpace_radial,1);
nor = size(kSpace_radial,2);
nof = size(kSpace_radial,3);
nc = size(kSpace_radial,4);
nSMS = size(kSpace_radial,5);
ns = size(kSpace_radial,6);
sx_over = N.sx_over;

kSpace_radial = reshape(kSpace_radial,[sx*nor*nof,nc*nSMS*ns]);

kSpace_cart = single(N.S*double(kSpace_radial));

kSpace_cart = reshape(kSpace_cart,[sx_over sx_over nof nc nSMS ns]);
