function showImage(Image,Cost)
% Image = crop_half_FOV(abs(Image));
Image = abs(Image);
[nx,ny,nof,x,nSMS,ns] = size(Image);
frame_num = floor(nof/4);
im = reshape(Image,[nx,ny,nof,x*nSMS*ns]);
if frame_num ~= 0
%     im = im(:,:,[frame_num frame_num*2 frame_num*3],round(x*nSMS*ns/2));
im = im(:,:,[frame_num frame_num*2 frame_num*3],1);
%   im = im(:,:,:,1:3);
%   im = permute(im,[1 3 2 4]);
%   im = reshape(im,[nx*3 ny*3]);
im = im(:,:);
else
    im = im(:,:,1,:);
    im = squeeze(im);
    im = reshape(im,[nx ny*nSMS*ns*x]);
end

figure(100);
clf;
subplot(2,2,[1 3])
imagesc(im)
colormap gray
brighten(0.3)
axis image
axis off
        
subplot(2,2,[2 4])
plotCost(Cost)

drawnow
end
