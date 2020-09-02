function KB = kaiser_bessel_simple(x, kernel_length, alpha)
% KB = kaiser_bessel_simple(x, kernel_length, alpha)
%
% https://en.wikipedia.org/wiki/Kaiser_window
% Inputs:
%   x: values where to evaluate the function
%   kernel_length: KB kernel length
%   alpha: KB window parameter 

L = kernel_length/2;
KB = zeros(size(x));
ii = abs(x)<L;
f = alpha*sqrt(1-(x(ii)/L).^2);
KB(ii) = besseli(0,f)./besseli(0,alpha);