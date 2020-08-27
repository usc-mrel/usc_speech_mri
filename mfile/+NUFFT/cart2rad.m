function kSpace_radial = cart2rad(kSpace_cart,N)
%--------------------------------------------------------------------------
%   [kSpace_radial] = cart2rad(kSpace_cart,N)
%--------------------------------------------------------------------------
%   Interpolate k-space on non-Cartesian coordinates
%--------------------------------------------------------------------------
%   Inputs:
%       - kSpace_cart       [sx, sx, nof, ...]
%       - N                 [structure]
%
%           'sx'    input array size
%           'nof'   number of time frames
%
%       - kSpace_cart       input Cartesian array   
%       - N                 see 'help NUFFT.init.m'
%--------------------------------------------------------------------------
%   Output:
%       - kSpace_radial     [nsamples, nrep, nof, ...]
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

nof = N.size_data(3);
nc = size(kSpace_cart,4);
nSMS = size(kSpace_cart,5);
sx_over = N.sx_over;

kSpace_cart = reshape(kSpace_cart,[sx_over*sx_over*nof,nc*nSMS]);

kSpace_radial = single(N.S'*double(kSpace_cart));

kSpace_radial = reshape(kSpace_radial,[N.size_data,nc,nSMS]);