% Prior to this, please run demo_recon_parasweep_matlab.m to generate reconstructions with different regularization values. 

%% Clean state
clear all; close all; clc;

%% Read image
data_dir = '../dataset/sub015/figures';
output_dir = './figures/';
mkdir(output_dir);

recon_files = dir(fullfile(data_dir, '*.h5'));
lambda_list = {'0.008','0.08','0.8'};

for j = 1:length(lambda_list)
    for jj = 1:length(recon_files)
        if strfind(recon_files(jj).name, ['t_', lambda_list{j}])
            image = h5read(fullfile(recon_files(jj).folder, recon_files(jj).name),'/recon');
            image_array(:,:,:,j) = image./max(image(:));
        end
    end
end

clear image
%% Crop image
image_array = image_array(1:70, 15:end, 75:end, :);
[sx, sy, nof, ~] = size(image_array);

%% Select sagittal frame index and horizontal lines
figure;
imagesc(sum(image_array(:,:,:,3),3));
axis image off; 
colormap gray;
brighten(0.1);

frame_sag = 90; % sagittal frame index
y = 23; % location of the horizontal line shown in the sagittal frame
t_range_zoom = 400:599; % the time range of the dotted rectangular box
x_range_zoom = 8:55; % the x range of the dotted rectangular box

%% Display Figure 6
close all;
fig = figure('Color', 'k', 'Position',[0,0,840,720]);

% Figure 6a: sagittal view
h1 = subplot(1,3,1); 
imagesc(reshape(permute(squeeze(image_array(:,:,frame_sag,:)),[1, 3, 2]),[sy*length(lambda_list), sx]));
axis off; 
colormap gray; 
hold on; 
brighten(0.1);

plot([1,sy],[y,y],'LineWidth', 3, 'LineStyle', ':', 'Color', 'w');

for ii = 1:length(lambda_list)
    text(5, 7+(ii-1)*sy ,sprintf('\\lambda = %s', lambda_list{ii}), 'FontSize', 24, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'w');
end

% Figure 6b: intensity vs time profile
line_x = squeeze(image_array(y,:,:,:));
line_x = permute(line_x, [1,3,2]);
line_x = reshape(line_x, [sy*length(lambda_list), nof]);

h2 = subplot(1,3,2); 
imagesc(line_x); 
axis off; 
colormap gray; 
hold on; 
brighten(0.1);

plot([frame_sag,frame_sag],[1,sx],'LineWidth', 3, 'LineStyle', ':', 'Color', [0.8, 0.8, 0.8]);
plot([t_range_zoom(1),t_range_zoom(1),t_range_zoom(end),t_range_zoom(end),t_range_zoom(1)],[x_range_zoom(1),x_range_zoom(end),x_range_zoom(end),x_range_zoom(1),x_range_zoom(1)],'LineWidth', 3, 'LineStyle', ':', 'Color', [0.8, 0.8, 0.8])

% Figure 6c: zoomed in profile
line_x_zoom = squeeze(image_array(y, x_range_zoom, t_range_zoom,:));
line_x_zoom = permute(line_x_zoom, [1, 3, 2]);
line_x_zoom = reshape(line_x_zoom, [length(x_range_zoom)*length(lambda_list), length(t_range_zoom)]);

h3 = subplot(1,3,3); 
imagesc(line_x_zoom);
axis off; 
colormap gray; 
hold on; 
brighten(0.1);

set(h1, 'Position', [0      0 0.286 1]); % [left bottom width height]
set(h2, 'Position', [0.286  0 0.614 1]);
set(h3, 'Position', [0.9    0 0.1   1]);

% save figure
hgexport(fig, fullfile(output_dir, 'figure6.eps'));
