function Image = crop_half_FOV(Image, siz)
% Image = crop_half_FOV(Image, siz)
%
% crop image to half FOV for first two dimensions
%
%   Inputs:
%       Image: input image with at least two dimensions
%           dimensions: [sx, sy, ~]
%       siz: to what size the 2D image will be cropped. If not speficied,
%            Image will be cropped to [sx/2, sy/2, ~].

ndim = ndims(Image);
im_size = size(Image);
sx = im_size(1);
sy = im_size(2);
if ndim > 3
    Image = Image(:,:,:);
end
if nargin == 1
    siz = round([sx/2, sy/2]);
end
cut_x = round((sx - siz(1))/2);
cut_y = round((sy - siz(2))/2);

Image(1:cut_x, : ,:)      = [];
Image(siz(1)+1:end, : ,:) = [];
Image(:, 1:cut_y, :)      = [];
Image(:, siz(2)+1:end, :) = [];

Image = reshape(Image, [siz, im_size(3:end)]);
