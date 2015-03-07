function [ hs] = hsic_dis( X, Y, options)
% 
% HSIC for discrete output
% Compute a biased estimate of HSIC as defined in section 3.1
% of the paper ``Measuring Statistical Dependence with Hilbert-Schmidt 
% Norms''
%
% X is an m x n matrix where m is the dimension.
% 


[m n ] = size(X);

if size(Y,2) ~= n
    error('Sample size must be equal for X and Y');
end

if nargin < 2
    error('Number of inputs must be at least 2');
end

if nargin < 3
    options = [];
end

% Normalize X
X = normdata(X);

% Gaussian width for X (use pairwise median distance by default)
meddistx = meddistance(X);
sigmax = myProcessOptions(options, 'sigmax', meddistx);

options.sigmax = sigmax;

K = kerGaussian(X, X, sigmax);
L = kerDelta(Y, Y);

% H = eye(n) - repmat(1/n, n,n);
% KH = K*H;
%LH = L*H;
% LH = L - repmat(mean(L,2),1,n );
LH = bsxfun(@plus, L, -mean(L,2));

%hs = trace(KH*LH) / ((n-1)^2);
%hs = sum(sum(KH .* LH')) / ((n-1)^2);

%KHT = KH'; 
KHT = bsxfun(@minus, K, mean(K, 1) );

% See matrix cookbook section 10.2.2
hs = (KHT(:)' * LH(:) )/ ((n-1)^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
