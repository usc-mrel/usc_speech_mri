function y = kaiser_bessel_ft_simple(x, kernel_length, alpha)
% y = kaiser_bessel_ft_simple(x, kernel_length, alpha)
%
% https://en.wikipedia.org/wiki/Kaiser_window
% Inputs:
%   x: values where to evaluate the function
%   kernel_length: KB kernel length
%   alpha: KB window parameter 

x = kernel_length*x/alpha*pi;
x = alpha*sqrt(1-x.^2);
y = kernel_length*sinh(x)/besseli(0,alpha)./x;