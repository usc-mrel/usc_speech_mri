function [Image,para] = STCR_conjugate_gradient(Data,para)
%--------------------------------------------------------------------------
%   [Image,para] = STCR_conjugate_gradient(Data,para)
%--------------------------------------------------------------------------
%   Solve MRI reconstruction problem using a conjugate gradient method.
%--------------------------------------------------------------------------
%   Inputs (for a 2D dynamic spiral case):
%       - Data                      [structure] 
%           Data.kSpace             [sx, nos, nof, nc]
%           Data.sens_map           [1,  1,   1,   nc]
%           Data.first_est          [sx, sy,  nof]
%           Data.N                  [NUFFT structure]
%
%               'sx'    number of readout point along a spiral inteleave 
%               'sy'    for spiral k-space, same as sx
%               'nos'   number of spirals per time frame
%               'nof'   number of time frames
%               'nc'    number of coils
%           
%       - para                      [structure]
%           para.setting            [structure]
%               setting.ifplot      [0 or 1]
%               setting.ifGPU       [0 or 1]
%           para.Recon              [structure]
%               Recon.weight_tTV    [scalar]
%               Recon.weight_sTV    [scalar]
%               Recon.epsilon       [scalar]
%               Recon.step_size     [scalar]
%               Recon.noi           [positive integer]
%               Recon.type          [string]
%
%       - Data
%           Data.kSpace             measured k-space data "d"
%           Data.sens_map           sensitivity map
%           Data.first_est          initial estimation of "x": "A^H d"
%           Data.N                  NUFFT structure (see +NUFFT)
%
%       -para
%           para.setting.ifplot     display reconstruction process
%           para.setting.ifGPU      run function on a NVIDIA GPU
%           para.Recon.weight_tTV   "lambda_t"
%           para.Recon.weight_sTV   "lambda_s"
%           para.Recon.epsilon      "epsilon"
%           para.Recon.step_size    initial CG update step size
%           para.Recon.noi          number of iterations
%           para.Recon.type         reconstruction type see 
%                                   'compute_fidelity'
%--------------------------------------------------------------------------
%   Output:
%       - Image     [sx, sy, nof, ...]
%       - para      [structure]
%
%       - Image     reconstructed images "m"
%--------------------------------------------------------------------------
%   A standard cost function it solves is the spatially and temporally
%   constrained reconstruction (STCR):
%
%   || Am - d ||_2^2 + lambda_t || TV_t m ||_1 + lambda_s || TV_s m ||_1
%
%   "A"         sampling matrix includes sensitivity maps, Fourier 
%               transform, and undersampling mask
%   "m"         image to be reconstructed
%   "d"         measured k-space data
%   ||.||_2^2   l2 norm
%   ||.||_1     l1 norm
%   "lambda_t"  temporal constraint weight
%   "lambda_s"  sparial constraint weight
%   TV_t        temporal total variation (TV) operator (finite difference)
%               sqrt( abs(m_t+1 - m_t)^2 + epsilon )
%   "epsilon"   small term to aviod singularity
%   TV_s        spatial TV operator
%               sqrt( abs(m_x+1 - m_x)^2 + abs(m_y+1 - m_y) + epsilon )
%--------------------------------------------------------------------------
%   Reference:
%       [1]     Acquisition and reconstruction of undersampled radial data 
%               for myocardial perfusion MRI. JMRI, 2009, 29(2):466-473.
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

%% load reconstruction parameters and settings

fprintf([repmat('-', [1, 75]), '\n'])
disp('begin iterative STCR conjugate gradient reconstruction...');
fprintf([repmat('-', [1, 75]), '\n'])

disp_freq      = 1;
ifplot         = para.setting.ifplot;
ifGPU          = para.setting.ifGPU;
weight_tTV     = para.Recon.weight_tTV;
weight_sTV     = para.Recon.weight_sTV;
beta_sqrd      = para.Recon.epsilon;
para.Recon.step_size = para.Recon.step_size(1);


if isfield(Data,'first_guess')
    new_img_x = Data.first_guess;   
else
    new_img_x = single(Data.first_est);
end

if isfield(Data,'sens_map')
    if ~isfield(Data, 'sens_map_conj')
        Data.sens_map_conj = conj(Data.sens_map);
    end
end

if ifGPU
    Data.kSpace        = gpuArray(Data.kSpace);
    new_img_x          = gpuArray(new_img_x);
    Data.sens_map      = gpuArray(Data.sens_map);
    Data.sens_map_conj = gpuArray(Data.sens_map_conj);
    if isfield(Data,'mask')
        Data.mask          = gpuArray(Data.mask);
    end
    if isfield(Data,'filter')
        Data.filter        = gpuArray(Data.filter);
    end
%    Data.first_est = gpuArray(Data.first_est);
%    Data.phase_mod = gpuArray(Data.phase_mod);
%    Data.phase_mod_conj = gpuArray(Data.phase_mod_conj);
    beta_sqrd = gpuArray(beta_sqrd);
    if isfield(Data,'N')
        for i=1:length(Data.N)
            Data.N(i).S = gpuArray(Data.N(i).S);
            Data.N(i).Apodizer = gpuArray(Data.N(i).Apodizer);
            Data.N(i).W = gpuArray(Data.N(i).W);
        end
    end
    
end

% initialize Cost
para.Cost = struct('fidelityNorm',[],'temporalNorm',[],'spatialNorm',[],'totalCost',[]);

% initialize function handels 
fidelity = @(im) compute_fidelity(im,Data,para);
spatial  = @(im) compute_sTV(im,weight_sTV,beta_sqrd);
temporal = @(im) compute_tTV(im,weight_tTV,beta_sqrd);

fprintf(' Iteration       Cost       Step    Time(s) \n')
for iter_no = 1:para.Recon.noi

    if mod(iter_no,disp_freq) == 1 || iter_no == 1 || disp_freq == 1
        t1 = tic;
    end

%% update term (gradient of fidelity, temporal/spatial TV)

    tic; 
    [update_term,fidelity_norm] = fidelity(new_img_x);
    para.CPUtime.fidelity(iter_no) = toc;
    
    tic;
    update_term = update_term + temporal(new_img_x);
    para.CPUtime.tTV(iter_no) = toc;
    
    tic;
    update_term = update_term + spatial(new_img_x);
    para.CPUtime.sTV(iter_no) = toc;

%% conjugate gradient
    tic;
    if iter_no > 1
        beta = update_term(:)'*update_term(:)/(update_term_old(:)'*update_term_old(:)+eps('single'));
        update_term = update_term + beta*update_term_old;
    end
    update_term_old = update_term; clear update_term
    
%% line search    

    para.Cost = Cost_STCR(fidelity_norm, new_img_x, weight_sTV, weight_tTV, para.Cost); clear fidelity_update
    step_size = line_search(new_img_x,update_term_old,Data,para);
    para.Recon.step_size(iter_no) = step_size;

    new_img_x = new_img_x + step_size * update_term_old;
    para.CPUtime.update(iter_no) = toc;

%% plot&save part 

    if ifplot == 1
        showImage(new_img_x,para.Cost)
    end

%% break when step size too small or cost not changing too much

    if para.Recon.break && iter_no > 1
        if step_size < 1e-5
            break
        end
    end
    
    if mod(iter_no,disp_freq) == 0 || iter_no == para.Recon.noi
        fprintf(sprintf('%10.0f %10.2f %10.4f %10.2f \n',iter_no,para.Cost.totalCost(end),step_size,toc(t1)));
    end
end

Image = gather(new_img_x);
para = get_CPU_time(para);
fprintf(['Iterative STCR running time is ' num2str(para.CPUtime.interative_recon) 's' '\n'])
fprintf([repmat('-', [1, 75]), '\n'])
