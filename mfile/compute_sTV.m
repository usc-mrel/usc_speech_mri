function [sTV_update] = compute_sTV(img, weight, beta_sqrd)
%--------------------------------------------------------------------------
%   [sTV_update] = compute_sTV(img, weight, beta_sqrd)
%--------------------------------------------------------------------------
%   Compute the gradient of in-plane total variation
%--------------------------------------------------------------------------
%   Inputs:
%
%       - img           [sx, sy, ~]
%       - weight        [real scalar]
%       - beta_sqrt     [real scaler]
%
%       - img           image with at least two dimensions
%       - weight        regularization weight 
%       - beta_sqrt     a small term to aviod singularity
%--------------------------------------------------------------------------
%   Output:
%
%       - sTV_update    [sx, sy, ...]
%
%       - sTV_update    gradient of in-plane total variation
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
    siz = size(img);
    
    diff_x = diff(img,1,2);
    diff_y = diff(img,1,1);

    T1_num = cat(2,diff_x,zeros([siz(1),1,siz(3:end)]));
    T2_num = cat(2,zeros([siz(1),1,siz(3:end)]),diff_x); clear diff_x
    T3_num = cat(1,diff_y,zeros([1,siz(2:end)]));
    T4_num = cat(1,zeros([1,siz(2:end)]),diff_y); clear diff_y

    T1_den = sqrt(beta_sqrd + abs(T1_num).^2 + (abs((T3_num+T4_num)/2).^2)); clear T4_num
    T3_den = sqrt(beta_sqrd + abs(T3_num).^2 + (abs((T1_num+T2_num)/2).^2)); clear T2_num

    T1 = T1_num./T1_den; clear T1_den T1_num
    T3 = T3_num./T3_den; clear T3_den T3_num

    T2 = cat(2,zeros([siz(1),1,siz(3:end)]),T1(:,1:end-1,:,:,:,:));
    T4 = cat(1,zeros([1,siz(2:end)]),T3(1:end-1,:,:,:,:,:));

    sTV_update = weight .* (T1-T2+T3-T4);
else
    sTV_update = 0;
end

return