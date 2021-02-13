%% Clean state
clear all; close all; clc;

%% Read image
data_dir = '../dataset/';
output_dir = './figures/';
mkdir(output_dir);

img1 = h5read(fullfile(data_dir, 'sub035/2drt/recon/sub035_2drt_02_vcv2_r1_recon.h5'),'/recon');
img2 = h5read(fullfile(data_dir, 'sub051/2drt/recon/sub051_2drt_02_vcv2_r1_recon.h5'),'/recon');
img3 = h5read(fullfile(data_dir, 'sub058/2drt/recon/sub058_2drt_02_vcv2_r1_recon.h5'),'/recon');

%% Select sagittal frame index at /th/ in /uthu/ and vertical lines
t1 = 309;
t2 = 313;
t3 = 377;
x = 32;

%% Display Figure 2
fig = figure('Color', 'k', 'Position',[0,0,1200,400]);

h1 = subplot(1,3,1); 
imagesc(img1(:,:,t1));
axis image off; 
colormap gray
hold on;
plot([x,x], [17,65], 'LineWidth', 3, 'LineStyle', ':', 'Color', 'white')
text(3, 5, 'a', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white');

h2 = subplot(1,3,2); 
imagesc(img2(:,:,t2));
axis image off; 
colormap gray
hold on;
text(3, 5, 'b', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white');

h3 = subplot(1,3,3); 
imagesc(img3(:,:,t3));
axis image off; 
colormap gray
hold on;
text(3, 5, 'c', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white');

set(h1, 'Position', [0     0 0.333 1]); % [left bottom width height]
set(h2, 'Position', [0.333  0 0.333 1]);
set(h3, 'Position', [0.666  0 0.333 1]);

% save figure
hgexport(fig, fullfile(output_dir, 'figure2.eps'));
