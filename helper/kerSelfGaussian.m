function K = kerSelfGaussian(X, sigma)
%
% Gaussian kernel. 
% The same as kerGaussian(X, X, sigma) but a bit more efficient.
%

S = sum(X.^2,1)';
D2 = bsxfun(@plus, S, S') - 2*(X'*X);

K = exp(-D2./(2*sigma^2));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end