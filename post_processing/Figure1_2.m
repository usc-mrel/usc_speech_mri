ccc


frame_pick = 312;

%% read image
all_mat = dir('/Users/ytian/PycharmProjects/speech_open_dataset/ReconData/lac04*.mat');

all_t_weight = {'0.04','0.08','0.2','0.5','1'};

for j = 1:length(all_t_weight)
    for jj = 1:length(all_mat)
        if strfind(all_mat(jj).name, ['t_', all_t_weight{j}])
            load(fullfile(all_mat(jj).folder, all_mat(jj).name), 'Image_recon');
            image_all(:,:,:,j) = Image_recon;
        end
    end
end
all_t_weight = {'0.04','0.08','0.2','0.5','1.0'};
clear Image_recon
%% crop image
image_all = image_all(1:70, 15:end, 75:end, :);

[sx, sy, nof, ~] = size(image_all);
scale = max(max(max(image_all)));
image_all = image_all ./ scale;
nof = size(image_all, 3);

figure_position = figure;
imagesc(sum(image_all(:,:,:,3),3));
axis image
colormap gray
brighten(0.1)
axis off
% p = impoint;
% p = getPosition(p);

% x = round(p(2));
% y = round(p(1));
x = 24;
y = 30;

clf
imagesc(sum(image_all(:,:,frame_pick,1),3)); axis image; axis off
set(gcf, 'Position', [100, 100, 240, 240])
hold on
plot([1,sy],[x,x],'LineWidth', 3, 'LineStyle', '--')
% plot([y,y],[1,sx],'LineWidth', 3, 'LineStyle', '--')
set(gca,'pos',[0 0 1 1])
filename = sprintf('./figures/%s_%s_line_position.eps', all_mat(1).name(1:11), all_t_weight{1});
% title(sprintf('x = %g, y = %g', y, x), 'FontSize', 26)
text(5, 7 ,sprintf('\\lambda_t = %s', all_t_weight{1}), 'FontSize', 24, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')
% 
hgexport(figure_position, filename);

for ii = 2:5
    clf
    imagesc(sum(image_all(:,:,frame_pick,ii),3)); axis image; axis off
    set(gcf, 'Position', [100, 100, 240, 240])
%     hold on
%     plot([1,84],[x,x],'LineWidth', 3, 'LineStyle', '--')
%     plot([y,y],[1,84],'LineWidth', 3, 'LineStyle', '--')
    set(gca,'pos',[0 0 1 1])
    filename = sprintf('./figures/%s_%s_line_position.eps', all_mat(1).name(1:11), all_t_weight{ii});
    % title(sprintf('x = %g, y = %g', y, x), 'FontSize', 26)
    text(5, 7 ,sprintf('\\lambda_t = %s', all_t_weight{ii}), 'FontSize', 24, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')
    hgexport(figure_position, filename);
end


% sagital_im = squeeze(image_all(:,:,1,:));
% sagital_im = permute(sagital_im, [1, 3, 2]);
% sagital_im = reshape(sagital_im, [80*5, 80]);
% figure_position = figure;
% imagesc(sagital_im)
% axis image
% axis off
% colormap gray
% set(gcf, 'Position', [100, 0, 900/5, 900])
% set(gca,'pos',[0 0 1 1])
% 
% hold on
% plot([1,80],[x,x],'LineWidth', 3, 'LineStyle', '--')
% plot([y,y],[1,80],'LineWidth', 3, 'LineStyle', '--')
% 
% for ii=1:5
%     xx = 5;
%     yy = 8+80*(ii-1);
%     text(xx, yy ,sprintf('\\lambda_t = %s', all_t_weight{ii}), 'FontSize', 24, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'Color', 'white')
% end
% set(gca,'pos',[0 0 1 1])
% hgexport(figure_position, './figures/sagital.eps');


line_x = squeeze(image_all(x,:,:,:));
line_y = squeeze(image_all(:,y,:,:));

line_x = permute(line_x, [1,3,2]);
line_y = permute(line_y, [1,3,2]);

line_x = reshape(line_x, [sy*5, nof]);
line_y = reshape(line_y, [sx*5, nof]);

Colors = colors;

figure_line_x = figure;
imagesc(line_x)
colormap gray
brighten(0.4)
axis off
set(gcf, 'Position', [0,0,800,900])
patch([1,nof,nof,1], [sy*5,sy*5,1,1], Colors(1,:), 'FaceColor','none', 'EdgeColor', Colors(1,:), 'LineWidth', 8)
hold on
for jj=1:4
    plot([1,nof],[jj*sy, jj*sy],'LineWidth', 4, 'Color', Colors(1,:));
end
for jj=1:5
    x = nof/2;
    y = 12+sy*(jj-1);
%     text(x, y ,sprintf('\\lambda_t = %s', all_t_weight{jj}), 'FontSize', 24, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'Color', 'white')
end
filename = sprintf('./figures/%s_line_x.eps', all_mat(1).name(1:11));
set(gca,'pos',[0 0 1 1])
hgexport(figure_line_x, filename);

%{
figure_line_y = figure;
imagesc(line_y)
colormap gray
brighten(0.4)
axis off
set(gcf, 'Position', [0,0,700,900])
patch([1,nof,nof,1], [80*5,80*5,1,1], Colors(2,:), 'FaceColor','none', 'EdgeColor', Colors(1,:), 'LineWidth', 8)
hold on
for jj=1:4
    plot([1,nof],[jj*80, jj*80],'LineWidth', 4, 'Color', Colors(1,:));
end
for jj=1:5
    x = nof/2;
    y = 12+80*(jj-1);
%     text(x, y ,sprintf('\\lambda_t = %s', all_t_weight{jj}), 'FontSize', 24, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'Color', 'white')
end
filename = sprintf('./figures/%s_line_y.eps', all_mat(1).name(1:11));
set(gca,'pos',[0 0 1 1])
hgexport(figure_line_y, filename);
%}
%%
line_y_zoom = squeeze(image_all(24, 10:49,1651:1762,:));
line_y_zoom = permute(line_y_zoom, [1, 3, 2]);
line_y_zoom = reshape(line_y_zoom, [40*5, 112]);

figure_line_y = figure;
imagesc(line_y_zoom)
colormap gray
brighten(0.2)
axis off
set(gcf, 'Position', [0,0,180,900])
patch([1,112,112,1], [200.2,200.2,0.5,0.5], Colors(2,:), 'FaceColor','none', 'EdgeColor', Colors(2,:), 'LineWidth', 8)
hold on
for jj=1:4
    plot([1,112],[jj*40, jj*40],'LineWidth', 4, 'Color', Colors(2,:));
end
for jj=1:5
    x = 140/2 - 40;
    y = 4 + 20*(jj-1);
%     text(x, y ,sprintf('\\lambda_t = %s', all_t_weight{jj}), 'FontSize', 24, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'Color', 'white')
end
filename = sprintf('./figures/%s_line_y_zoom.eps', all_mat(1).name(1:11));
set(gca,'pos',[0 0 1 1])
hgexport(figure_line_y, filename);