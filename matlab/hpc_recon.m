%% add ismrmd and mfile path
addpath ../../ismrmrd/matlab/
addpath ../mfile/

files = dir( fullfile(path_to_data, '*.h5') );

for file = files'

    %% change the bellowing for running a different dataset
    para.dir.raw_file   = fullfile(file.folder, file.name);
    para.dir.output_dir = path_to_output;

    %% set parameters
    para.setting.ifplot = 0;        % set to 0 for running on server
    para.setting.ifGPU  = 1;         % set to 1 when you want to use GPU
    para.Recon.time_frames = 'all'; % set to 'all' for running on server

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

    [~, examname] = fileparts(para.dir.raw_file);
    para.dir.save_recon = fullfile(para.dir.output_dir, sprintf('%s_narm_%g_t_%.5f_s_%.5f_iter_%g_.h5', examname, para.Recon.narm, para.weight_tTV, para.weight_sTV, para.Recon.noi));

    %% do the recon
    try
        speech_open_dataset_reconstruction(para)
    catch
        warning('Could not reconstruct: %s', para.dir.raw_file)
    end
end