function [ X,Y,D] = gen_sca3( n, seed )
%
% 2 correct features 
% Similar to Data3 in Sufficient Component Analysis paper. 
% Totally 10 dimensions.
%


% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


X1 = randn(1, n);
X2 = randn(1, n);

X3_4 = 0.5*[X1;X2] + 2*rand(2, n) - 1;
X5_10 = randn(6, n);

Y = (X1.^2 + X2) ./ (0.5 + (X2 + 1.5).^2 ) + 0.1*randn(1,n);
X = [X1 ; X2; X3_4;X5_10];
D = {[1 2]};

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);


end

