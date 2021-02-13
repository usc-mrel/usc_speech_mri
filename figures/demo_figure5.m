%% Clean state
clear all; close all; clc;

%% Read image and audio
data_dir = '../dataset/';
output_dir = './figures/';
mkdir(output_dir);

img1 = h5read(fullfile(data_dir, 'sub035/2drt/recon/sub035_2drt_05_shibboleth_r1_recon.h5'),'/recon');
img2 = h5read(fullfile(data_dir, 'sub041/2drt/recon/sub041_2drt_05_shibboleth_r1_recon.h5'),'/recon');

[audio1, Fs] = audioread(fullfile(data_dir, 'sub035/2drt/audio/sub035_2drt_05_shibboleth_r1_audio.wav'));
[audio2,  ~] = audioread(fullfile(data_dir, 'sub041/2drt/audio/sub041_2drt_05_shibboleth_r1_audio.wav'));

duration_in_sec1 = 5.6;
duration_in_sec2 = 7.1;

% for image
y_loc1 = 33;
y_loc2 = 36;
t1 = 349;
t2 = 444; 

Fr = 1000/(6.004*2);
n_frames1 = floor(Fr*duration_in_sec1);
n_frames2 = floor(Fr*duration_in_sec2);

% for audio 
win_len = 0.04;
win_shift = 0.01;
win_samps = round(win_len * Fs);
shift_samps = round(win_shift*Fs);

n_samples1 = round(duration_in_sec1/((length(audio1)-1)/Fs)*(length(audio1)-1));
n_samples2 = round(duration_in_sec2/((length(audio2)-1)/Fs)*(length(audio2)-1));

%% Display Figure 5
fig = figure('Color', 'w', 'Position',[0,0,800,850]);

h1 = subplot(4,2,1); 
imagesc(img1(:,:,t1));
brighten(0.1);
axis off; 
hold on;
plot([1, 84], [y_loc1, y_loc1], 'LineWidth', 5, 'LineStyle', ':', 'Color', 'white')
text(3, 5, 'a', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white');


h2 = subplot(4,2,2); 
imagesc(squeeze(img1(y_loc1, :, 1:n_frames1)));
brighten(0.1);
axis([Fr duration_in_sec1*Fr 1 84]);
axis off;
% set(gca,'XTick',0:round(Fr*1):n_frames1);
% set(gca,'XTickLabel', 0:1:n_frames1/Fr);
hold on;
plot([t1,t1], [1,84], 'LineWidth', 5, 'LineStyle', ':', 'Color', [0.5, 0.5, 0.5])


h5 = subplot(4,2,5); 
imagesc(img2(:,:,t2));
brighten(0.1);
axis off; 
hold on;
plot([1, 84], [y_loc2, y_loc2], 'LineWidth', 5, 'LineStyle', ':', 'Color', 'white')
text(3, 5, 'b', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white');


h6 = subplot(4,2,6); 
imagesc(squeeze(img2(y_loc2, :, 1:n_frames2)));
brighten(0.1);
axis([Fr duration_in_sec2*Fr 1 84]);
axis off;
% set(gca,'XTick',0:round(Fr*1):n_frames2);
% set(gca,'XTickLabel', 0:1:n_frames2/Fr);
hold on;
plot([t2,t2], [1,84], 'LineWidth', 5, 'LineStyle', ':', 'Color', [0.5, 0.5, 0.5])
colormap gray;


h4 = subplot(4,2,4); 
spectrogram(audio1(1:n_samples1,1), win_samps, win_samps-shift_samps, 1024, Fs,'yaxis'); 
axis([1 duration_in_sec1 1 9.5]);
% axis off;
colormap(h4,'jet'); 
colorbar off;
grid on;
grid minor;


h8 = subplot(4,2,8); 
spectrogram(audio2(1:n_samples2,1), win_samps, win_samps-shift_samps, 1024, Fs,'yaxis'); 
axis([1 duration_in_sec2 1 9.5]);
% axis off;
colormap(h8,'jet'); 
colorbar off;
grid on;
grid minor;

set(h1, 'Position', [0     0.73  0.27 0.27]); % [left bottom width height]
set(h2, 'Position', [0.27  0.73  0.73 0.27]);
set(h4, 'Position', [0.27  0.52  0.73 0.21]);
set(h5, 'Position', [0     0.23  0.27 0.27]); 
set(h6, 'Position', [0.27  0.23  0.73 0.27]);
set(h8, 'Position', [0.27  0.02  0.73 0.21]);

% save figure
hgexport(fig, fullfile(output_dir, 'figure5.eps'));
