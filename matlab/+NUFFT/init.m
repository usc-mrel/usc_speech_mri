function N = init(kx,ky,over_sampling,kernel_size,sx,skx)
%--------------------------------------------------------------------------
%   [N] = init(kx, ky, over_sampling, kernel_size, sx, skx)
%--------------------------------------------------------------------------
%   Create NUFFT structure
%--------------------------------------------------------------------------
%   Inputs:
%       - kx                [nsamples, nrep, nof, ...]
%       - ky                [nsamples, nrep, nof, ...]
%       - over_sampling     [positive integer]
%       - kernel_size       [1, 2]
%       - sx                [positive integer]
%       - skx (optional)    [positive integer]
%
%           'nsamples'  number of samples per readout (a radial ray or
%                       spiral arm)
%           'nrep'      number of repetetions per time frame (number of 
%                       radial rays or spiral arms)
%           'nof'       number of time frames
%
%       - kx, ky            k-space coordinates
%       - over_sampling     over sampling factor
%       - kernel_size       Kaiser-Bessel kernel size
%       - sx                Cartesian image size
%       - skx               Cartesian k-space size
%--------------------------------------------------------------------------
%   Output:
%       - N                 [structure]
%           N.Apodizer      [sx, sx]
%           N.S             [sparse matrix]
%           N.kernel_size   [1, 2]
%           N.sx_over       [positive integer]
%           N.size_data     [nsamples, nrep, nof]
%           N.size_image    [1, 2]
%           N.size_kspace   [1, 2]
%           N.W             [nsamples, 1]
%
%       - N.Apodizer        apodizer in image space to compensate intensity
%                           coming from K-B convolution
%       - N.S               a sparse matrix that maps non-Cartesian k-space
%                           onto a Cartesian grid and does the K-B
%                           interpolation. This is the main matrix that we
%                           calculate in this function.
%       - N.kernel_size     how large is the K-B convolution kernel size
%       - N.sx_over         Cartesian k-space size
%       - N.size_data       input data size
%       - N.size_image      Cartesian image size. Note that this can be
%                           different from the gridded k-space size, since
%                           some people like to grid on a finner grid,
%                           which will yeild a larger FOV in image space,
%                           and than crop this image to be the size they
%                           want.
%       - N.size_kspace     Cartesian k-space size
%       - N.W               density compensation function for radial
%--------------------------------------------------------------------------
%   I coded it this way, but there are a lot of variations. The k-space
%   coordinates are normalized to the matrix size, or the Cartesian k-space
%   size that I want to use. So be careful that skx = sx * over_sampling
%   has to be always true. If skx is not given, then it calculates it from
%   the sx and over_sampling.
%   However, if skx ~= sx * over_sampling, the function will do
%   zero-padding automatically.
%   In this way, I can control every thing I want: zero padding, Cartesian
%   grid size, image size, and image FOV.
%--------------------------------------------------------------------------
%   Reference:
%       [1] Nonuniform Fast Fourier Transforms Using Min-Max Interpolation.
%           IEEE T-SP, 2003, 51(2):560-74. 
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

Nsamples = size(kx,1);
Nrep = size(kx,2);
nof = size(kx,3);

if ~exist('skx')
    skx = round(sx*over_sampling);
end

kx = kx*over_sampling;
ky = ky*over_sampling;

x_cart = zeros(Nsamples,Nrep,nof,kernel_size(1));
y_cart = zeros(Nsamples,Nrep,nof,kernel_size(2));

if mod(kernel_size(1),2) == 0
    x_cart(:,:,:,1) = floor(kx) - kernel_size(1)/2 + 1;
else
    x_cart(:,:,:,1) = round(kx) - (kernel_size(1)-1)/2;
end
add_x(1,1,1,:) = 1:kernel_size(1)-1;
x_cart(:,:,:,2:end) = bsxfun(@plus,x_cart(:,:,:,1),add_x);

if mod(kernel_size(2),2) == 0
    y_cart(:,:,:,1) = floor(ky) - kernel_size(2)/2 + 1;
else
    y_cart(:,:,:,1) = round(ky) - (kernel_size(2)-1)/2;
end
add_y(1,1,1,:) = 1:kernel_size(2)-1;
y_cart(:,:,:,2:end) = bsxfun(@plus,y_cart(:,:,:,1),add_y);

x_cart = repmat(x_cart,1,1,1,kernel_size(2));
x_cart = reshape(x_cart,Nsamples,Nrep,nof,prod(kernel_size));
y_cart = permute(y_cart,[1,2,3,5,4]);
y_cart = repmat(y_cart,1,1,1,kernel_size(1));
y_cart = reshape(y_cart,Nsamples,Nrep,nof,prod(kernel_size));

dx = round((x_cart - kx)*100)/100;
dy = round((y_cart - ky)*100)/100;

%%% shift image phase
phase = exp(-1i*pi*(x_cart+y_cart)/over_sampling);

%%% kaiser bessel kernel
alpha = 2.34 * kernel_size(1);
% kb = @(k,J)kaiser_bessel(k,J,alpha,0); 03/30/20 Ye
kb = @(x,kernel_length) kaiser_bessel_simple(x,kernel_length,alpha);
kb_weight_x = feval(kb,dx,kernel_size(1));
kb_weight_y = feval(kb,dy,kernel_size(2));

weight_kb = kb_weight_x.*kb_weight_y;
weight_kb = weight_kb.*phase;
weight_kb = permute(weight_kb,[1,2,4,3]);
weight_kb = reshape(weight_kb,Nsamples*Nrep*prod(kernel_size),nof);

x_cart = mod(x_cart,skx); x_cart(x_cart==0) = skx;
y_cart = mod(y_cart,skx); y_cart(y_cart==0) = skx;

indx = sub2ind([skx,skx,nof],x_cart,y_cart);
indx = permute(indx,[1 2 4 3]);
indx = bsxfun(@plus,indx,permute(0:skx*skx:skx*skx*(nof-1),[3 4 1 2]));

rad_num = repmat((1:Nsamples*Nrep).',[prod(kernel_size),1]);
rad_num = bsxfun(@plus,rad_num,0:Nsamples*Nrep:Nsamples*Nrep*(nof-1));

S = sparse(indx(:),rad_num(:),weight_kb(:),skx*skx*nof,Nsamples*Nrep*nof);

if over_sampling < 1
    NC = (0:skx-1)'-(skx-1)/2;
else
    NC = (0:sx-1)'-(sx-1)/2;
end
% tmpx = 1 ./ kaiser_bessel_ft(NC/sx_over, kernel_size(1), alpha, 0, 1);
% tmpy = 1 ./ kaiser_bessel_ft(NC/sx_over, kernel_size(2), alpha, 0, 1);
% N.Apodizer = single(tmpx * tmpy');

% 03/30/2020 Ye 
tmpx = 1./kaiser_bessel_ft_simple(NC/skx, kernel_size(1), alpha);
tmpy = 1./kaiser_bessel_ft_simple(NC/skx, kernel_size(2), alpha);

N.Apodizer = single(tmpx * tmpy');

%%%
N.S = S;
N.kernel_size = kernel_size;
N.sx_over = skx;
N.size_data = [Nsamples Nrep nof];
N.size_image = [sx,sx];
N.size_kspace = [skx,skx];

% N.W = designFilter(sx,-1,'ram-lak');
