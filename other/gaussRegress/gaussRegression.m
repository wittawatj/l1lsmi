function [f, Beta] = gaussRegression(X, Y, sigma, lambda)
%
% Gaussian kernel regression.
% X = n x m
% 
if nargin < 4
    lambda = 1e-3;
end

if nargin < 3
    sigma = meddistance(X);
end

n = size(X,2);
K = kerGaussian(X, X, sigma);
Beta = (K + lambda*eye(n)) \ Y';

f = @(nx)(Beta'*kerGaussian(X, nx, sigma));

%%%%%%%%%%%%%%
end

