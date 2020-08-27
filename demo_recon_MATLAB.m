%% add ismrmd and mfile path
addpath /usr/local/share/ismrmrd/matlab/
addpath ./mfile/
ccc

%% change the bellowing for running a different dataset
para.dir.raw_file = './data/lac01132019_19_28_53.h5';

%% set parameters
para.setting.ifplot = 1;        % set to 0 for running on server
para.setting.ifGPU = 0;         % set to 1 when you want to use GPU
para.Recon.time_frames = 1:20; % set to 'all' for running on server

%%
para.weight_tTV = 0.08;
para.weight_sTV = 0;

para.Recon.narm = 2;
para.Recon.FOV = 1.25;

para.Recon.epsilon = eps('single');
para.Recon.step_size = 2;
para.Recon.ifContinue = 0;
para.Recon.noi = 150; % number of iterations
para.Recon.type = '2D Spiral server'; % stack of spiral
para.Recon.break = 1;

para.dir.save_recon = sprintf('%s_narm_%g_t_%.5f_s_%.5f_iter_%g_.h5', para.dir.raw_file(1:end-3), para.Recon.narm, para.weight_tTV, para.weight_sTV, para.Recon.noi);

%% do the recon
try
    speech_open_dataset_reconstruction(para)
catch
    para.setting.ifGPU = 0;
    speech_open_dataset_reconstruction(para)
end