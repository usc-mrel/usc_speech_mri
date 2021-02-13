clear all; close all; clc;

%% add ismrmd and mfile path
addpath ../ismrmrd/matlab/
addpath ./matlab/

%% load raw data and save recon file directories
para.parent_dir = '../data/';
para.dir.subj = 'sub015';
para.dir.task = '2drt_01_vcv1_r1';
para.dir.raw_file = fullfile(para.parent_dir, para.dir.subj, 'raw', sprintf('%s_%s_raw.h5', para.dir.subj, para.dir.task));
para.dir.save_recon = fullfile(para.parent_dir, para.dir.subj, 'recon', sprintf('%s_%s_recon.h5', para.dir.subj, para.dir.task));
if ~isfolder(fullfile(para.parent_dir, para.dir.subj, 'recon'))
    mkdir(fullfile(para.parent_dir, para.dir.subj, 'recon'))
end

%% set parameters
para.setting.ifplot = 1;        % display image and cost during reconstruction
para.setting.ifGPU = 0;         % set to 1 when you want to use GPU
para.Recon.time_frames = 1:100; % set to 'all' for reconstructing all frames

para.weight_tTV = 0.08;         % temporal regularization parameter
para.weight_sTV = 0;            % spatial regularization parameter

para.Recon.narm = 2;            % number of arms per frame
para.Recon.FOV = 1.25;          % reconstruction FOV

para.Recon.epsilon = eps('single');
para.Recon.step_size = 2;
para.Recon.ifContinue = 0;
para.Recon.noi = 150; % number of iterations
para.Recon.type = '2D Spiral server';
para.Recon.break = 1;

%% do the recon
speech_open_dataset_reconstruction(para)
