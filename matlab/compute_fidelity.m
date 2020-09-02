function [fidelity_update,fidelity_norm] = compute_fidelity(image,Data,para)
%--------------------------------------------------------------------------
%   [fidelity_update, fidelity_norm] 
%       = compute_fidelity(image, Data, para)
%--------------------------------------------------------------------------
%   Compute fidelity update term of a MRI reconstruction problem
%--------------------------------------------------------------------------
%   Inputs:      
%       - image             [sx, sy, nof, ...]
%       - Data              [structure]
%       - para              [structure]
%           Recon.type      [string]
%
%       - image             image
%       - Data              see 'help STCR_conjugate_gradient.m'
%       - para              see 'help STCR_conjugate_gradient.m'
%       - para.Recon.type   reconstruction type
%--------------------------------------------------------------------------
%   Output:
%       - fidelity_update   [sx, sy, nof, ...]
%       - fidelity_norm     [scalar]
%
%       - fidelity_update   A^H (Am - d)
%       - fidelity_norm     || Am - d ||_2^2
%--------------------------------------------------------------------------
%   A standard fidelity term it solves is:
%
%   || Am - d ||_2^2
%
%   and the output is:
%
%   A^H (Am - d)
%
%   see 'help STCR_conjugate_gradient.m' for more information.
%--------------------------------------------------------------------------
%   Reference:
%       [1]     Acquisition and reconstruction of undersampled radial data 
%               for myocardial perfusion MRI. JMRI, 2009, 29(2):466-473.
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

switch para.Recon.type
    
    case '2D Spiral server'
        
        fidelity_update_all = zeros(size(image),class(image));
        fidelity_norm = 0;
        for i=1:para.Recon.no_comp
            fidelity_update = bsxfun(@times,image,Data.sens_map(:,:,:,i));
            kSpace_spiral = NUFFT.NUFFT(fidelity_update,Data.N);
            kSpace_spiral = Data.kSpace(:,:,:,i) - kSpace_spiral;
            fidelity_norm = fidelity_norm + sum(abs(vec(kSpace_spiral.*(Data.N.W).^0.5)).^2)/prod(Data.N.size_kspace);
            fidelity_update = NUFFT.NUFFT_adj(kSpace_spiral,Data.N);
            fidelity_update = bsxfun(@times,fidelity_update,Data.sens_map_conj(:,:,:,i));
            fidelity_update_all = fidelity_update_all + fidelity_update;
        end
        fidelity_norm   = sqrt(fidelity_norm)/2;
        fidelity_update = fidelity_update_all;

end

%fidelity_update = Data.first_est - fidelity_update;