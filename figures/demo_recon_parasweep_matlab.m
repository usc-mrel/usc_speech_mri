%% add ismrmd and mfile path
clear all; close all; clc;

addpath ../ismrmrd/matlab/
addpath ./matlab/
%% change the below for running a different dataset
para.dir.data_dir = '../dataset/';
para.dir.subj = 'sub015';
para.dir.filename = 'sub015_2drt_01_vcv1_r1_raw.h5';
para.dir.output_dir = fullfile(para.dir.data_dir, para.dir.subj, 'figures');
para.dir.raw_file = fullfile(para.dir.data_dir, para.dir.subj, '2drt', 'raw', para.dir.filename);

mkdir (para.dir.output_dir)
%% set parameters
para.setting.ifplot = 1;        % set to 0 for running on server
para.setting.ifGPU = 0;         % set to 1 when you want to use GPU
para.Recon.time_frames = 1:1700; % set to 'all' for running on server
%%
para.weight_sTV = 0;

para.Recon.narm = 2;
para.Recon.FOV = 1.25;

para.Recon.epsilon = eps('single');
para.Recon.step_size = 2;
para.Recon.ifContinue = 0;
para.Recon.noi = 150; % number of iterations
para.Recon.type = '2D Spiral server'; % stack of spiral
para.Recon.break = 1;

para.weight_tTV = 0.08;

t_TV = [0.008, 0.08, 0.8];
for i = 1:length(t_TV)
    para.weight_tTV = t_TV(i);
    
    para.dir.save_recon = fullfile(para.dir.output_dir, ...
        sprintf('%s_narm_%g_t_%.5f_iter_%g.h5', para.dir.filename(1:end-7),para.Recon.narm, para.weight_tTV, para.Recon.noi));

%% do the recon
    try
        speech_open_dataset_reconstruction(para)
    catch
        para.setting.ifGPU = 0;
        speech_open_dataset_reconstruction(para)
    end
end
