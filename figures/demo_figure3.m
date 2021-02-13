%% Clean state
clear all; close all; clc;

%% Read image
data_dir = '../dataset/';
output_dir = './figures/';
mkdir(output_dir);

img1 = h5read(fullfile(data_dir, 'sub035/recon/sub035_2drt_11_postures_r1_recon.h5'),'/recon');
img2 = h5read(fullfile(data_dir, 'sub035/recon/sub035_2drt_02_vcv2_r1_recon.h5'),'/recon');
img3 = h5read(fullfile(data_dir, 'sub035/recon/sub035_2drt_04_bvt_r1_recon.h5'),'/recon');
img4 = h5read(fullfile(data_dir, 'sub035/recon/sub035_2drt_06_rainbow_r1_recon.h5'),'/recon');

%% Trim the first 100 frames of transient state
img1(:,:,1:100) = [];
img2(:,:,1:100) = [];
img3(:,:,1:100) = [];
img4(:,:,1:100) = [];

%% Select the range of time 
duration_in_sec = 20;
x = 32;
y_range = 17:65; 

fr = 1000/(6.004*2); % frame rate
n_frames = floor(fr*duration_in_sec); % number of frames

%% Display Figure 3
fig = figure('Color', 'k', 'Position',[0,0,1200,800]);

h1 = subplot(4,1,1); 
imagesc(squeeze(img1(y_range, x, 1:n_frames)));
axis off; 
colormap gray;

h2 = subplot(4,1,2); 
imagesc(squeeze(img2(y_range, x, 1:n_frames)));
axis off; 
colormap gray;

h3 = subplot(4,1,3); 
imagesc(squeeze(img3(y_range, x, 1:n_frames)));
axis off; 
colormap gray;

h4 = subplot(4,1,4); 
imagesc(squeeze(img4(y_range, x, 1:n_frames)));
axis off; 
colormap gray;

set(h1, 'Position', [0 0.75 1 0.25]); % [left bottom width height]
set(h2, 'Position', [0 0.50 1 0.25]);
set(h3, 'Position', [0 0.25 1 0.25]);
set(h4, 'Position', [0 0    1 0.25]);

% save figure
hgexport(fig, fullfile(output_dir, 'figure3.eps'));
