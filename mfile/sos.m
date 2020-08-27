function img = sos(img, dim)
%--------------------------------------------------------------------------
%   [img] = sos(img, dim)
%--------------------------------------------------------------------------
%   Square root of sum-of-squares combination
%--------------------------------------------------------------------------
%   Inputs:      
%       - img               [any dimension]
%       - dim (optional)    [positive integer]
%
%       - img               input array
%       - dim               on which dimension to perform the sos. default
%                           is the last dimension
%--------------------------------------------------------------------------
%   Output:
%       - img               [one less dimension than input]
%
%       - img               sos result
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

if nargin == 1
    dim = ndims(img);
end
img = sqrt(sum(conj(img).*img, dim));
