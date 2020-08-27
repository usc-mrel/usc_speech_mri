function fidelity_norm = compute_fidelity_for_line_search(image, Data, para)
%--------------------------------------------------------------------------
%   [fidelity_norm] = compute_fidelity(image, Data, para)
%--------------------------------------------------------------------------
%   Compute fidelity norm of a MRI reconstruction problem
%--------------------------------------------------------------------------
%   Inputs:      
%       - image             [sx, sy, nof, ...]
%       - Data              [structure]
%       - para              [structure]
%
%       - image             image
%       - Data              see 'help STCR_conjugate_gradient.m'
%       - para              see 'help STCR_conjugate_gradient.m'
%--------------------------------------------------------------------------
%   Output:
%       - fidelity_norm     [scalar]
%
%       - fidelity_norm     || Am - d ||_2^2
%--------------------------------------------------------------------------
%   A standard fidelity term it solves is:
%
%   || Am - d ||_2^2
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

        fidelity_norm = 0;
        for i = 1:para.Recon.no_comp
            fidelity_update = bsxfun(@times,image,Data.sens_map(:,:,:,i));
            kSpace_spiral = NUFFT.NUFFT(fidelity_update,Data.N);
            kSpace_spiral = Data.kSpace(:,:,:,i) - kSpace_spiral;
            fidelity_norm = fidelity_norm + sum(abs(vec(kSpace_spiral.*(Data.N.W).^0.5)).^2)/prod(Data.N.size_kspace);
        end
        fidelity_norm   = sqrt(fidelity_norm)/2;

end
        
end