ccc

% figure 2
% dataset 1 excellent

image = h5read('../data/sub035_sc02_recon.h5','/recon');

% cut frames that are not in steady-state
image(:,:,1:50) = [];

x = 32;

line_x = squeeze(image(17:60, x, :));

% line profile sc1 
f = figure;
imagesc(line_x)
colormap gray
axis off
set(gcf, 'Position', [0, 0, 1000, 200])
set(gca,'pos',[0 0 1 1])
hold on
text(3, 5, 'SC02', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/line_x_sub035_sc02.eps')

% sagital image
f = figure;
imagesc(image(:,:,380));
axis image
axis off
colormap gray
set(gcf, 'Position', [0, 0, 400, 400]);
set(gca, 'pos', [0,0,1,1])

hold on
plot([x,x], [17,60], 'LineWidth', 6, 'LineStyle', '--')
text(3, 5, '(a)', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/sagital_sub035.eps')

% line profile 2


image = h5read('../data/sub035_sc05_recon.h5','/recon');
image(:,:,1:70) = [];

x = 32;

line_x = squeeze(image(17:60, x, :));

f = figure;
imagesc(line_x)
colormap gray
axis off
set(gcf, 'Position', [0, 0, 1000, 200])
set(gca,'pos',[0 0 1 1])
text(3, 5, 'SC05', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/line_x_sub035_sc05.eps')

%% another dataset 
% with low SNR

image = h5read('../data/sub041_sc03_recon.h5','/recon');

% cut frames that are not in steady-state
image(:,:,1:70) = [];

x = 32;

line_x = squeeze(image(17:65, x, :));

% line profile sc1 
f = figure;
imagesc(line_x)
colormap gray
axis off
set(gcf, 'Position', [0, 0, 1000, 200])
set(gca,'pos',[0 0 1 1])
text(3, 5, 'SC03', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/line_x_sub041_sc03.eps')

% sagital image
f = figure;
imagesc(image(:,:,75));
axis image
axis off
colormap gray
set(gcf, 'Position', [0, 0, 400, 400]);
set(gca, 'pos', [0,0,1,1])
brighten(0.1)
hold on
plot([x,x], [17,65], 'LineWidth', 6, 'LineStyle', '--')
text(3, 5, '(b)', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/sagital_sub041.eps')

% line profile 2


image = h5read('../data/sub041_sc06_recon.h5','/recon');
image(:,:,1:70) = [];


line_x = squeeze(image(17:65, x, :));

f = figure;
imagesc(line_x)
colormap gray
axis off
set(gcf, 'Position', [0, 0, 1000, 200])
set(gca,'pos',[0 0 1 1])
text(3, 5, 'SC06', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/line_x_sub041_sc06.eps')



%% another dataset 
% with ring

image = h5read('../data/sub058_sc04_recon.h5','/recon');

% cut frames that are not in steady-state
image(:,:,1:80) = [];

x = 31;

line_x = squeeze(image(17:60, x, :));

% line profile sc1 
f = figure;
imagesc(line_x)
colormap gray
axis off
set(gcf, 'Position', [0, 0, 1000, 200])
set(gca,'pos',[0 0 1 1])
text(3, 5, 'SC04', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/line_x_sub058_sc04.eps')

% sagital image
f = figure;
imagesc(image(:,:,228));
axis image
axis off
colormap gray
set(gcf, 'Position', [0, 0, 400, 400]);
set(gca, 'pos', [0,0,1,1])

hold on
plot([x,x], [17,65], 'LineWidth', 6, 'LineStyle', '--')
text(3, 5, '(c)', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/sagital_sub058.eps')

% line profile 2


image = h5read('../data/sub058_sc18_recon.h5','/recon');
image(:,:,1:70) = [];


line_x = squeeze(image(17:60, x, :));

f = figure;
imagesc(line_x)
colormap gray
axis off
set(gcf, 'Position', [0, 0, 1000, 200])
set(gca,'pos',[0 0 1 1])
text(3, 5, 'SC18', 'FontSize', 38, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')

hgexport(f, './figures/figure2/line_x_sub058_sc18.eps')