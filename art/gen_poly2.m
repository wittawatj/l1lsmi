function [X,Y,D] = gen_poly2(n, seed)

% Set the RandStream to use the seed
oldRs = RandStream.getGlobalStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setGlobalStream(rs);          


X1 = (2*rand(2, n) - 1);
X2 = randn(8, n);


X = [X1;X2];
Y = -X1(1,:).*2 + 2*X1(2,:) + randn(1, n);
D = {1:2};


% Set RandStream back to its original one
RandStream.setGlobalStream(oldRs);


end

