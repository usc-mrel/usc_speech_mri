function [tTV_update] = compute_tTV(img, weight, beta_sqrd)
%--------------------------------------------------------------------------
%   [tTV_update] = compute_tTV(img, weight, beta_sqrd)
%--------------------------------------------------------------------------
%   Compute the gradient of temporal total variation (3rd dimension)
%--------------------------------------------------------------------------
%   Inputs:      
%       - img           [sx, sy, nof, ...]
%       - weight        [real scalar]
%       - beta_sqrt     [real scaler]
%
%       - img           image with at least three dimensions
%       - weight        regularization weight 
%       - beta_sqrt     a small term to aviod singularity
%--------------------------------------------------------------------------
%   Output:
%       - tTV_update    [sx, sy, nof, ~]
%
%       - tTV_update    gradient of 3rd dimension total variation
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

if nargin < 3
    beta_sqrd = eps('single');
    if nargin < 2
        weight = 1;
    end
end

if weight~=0
    temp_a = diff(img,1,3);
    temp_b = temp_a./(sqrt(beta_sqrd+(abs(temp_a).^2)));
    temp_c = diff(temp_b,1,3);
    tTV_update = weight .* cat(3,temp_b(:,:,1,:,:,:),temp_c,-temp_b(:,:,end,:,:,:));
else
    tTV_update = 0;
end

end