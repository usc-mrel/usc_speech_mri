clear all; close all; clc;

%% add ismrmd and mfile path
addpath ../ismrmrd/matlab/
addpath ./matlab/

%% change the below for running a different data
para.parent_dir = '../data/';
para.dir.subj = 'sub015';
para.dir.task = '_2drt_01_vcv1_r1';
para.dir.raw_file = fullfile(para.parent_dir, para.dir.subj, 'raw', sprintf('%s_%s_raw.h5', para.dir.subj, para.dir.task));
para.dir.save_recon = fullfile(para.parent_dir, para.dir.subj, 'recon', sprintf('%s_%s_recon.h5', para.dir.subj, para.dir.task));

%% set parameters
para.setting.ifplot = 1;        % set to 0 for running on server
para.setting.ifGPU = 0;         % set to 1 when you want to use GPU
para.Recon.time_frames = 1:100; % set to 'all' for running on server

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

%% do the recon
try
    speech_open_dataset_reconstruction(para)
catch
    para.setting.ifGPU = 0;
    speech_open_dataset_reconstruction(para)
end