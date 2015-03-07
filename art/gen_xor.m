function [X,Y,D] = gen_xor(n, seed)
% 
% Xor problem.
% 

% Set the RandStream to use the seed
oldRs = RandStream.getGlobalStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setGlobalStream(rs);          


X1 = randi([0 1], 2, n); % 50/50%
X2 = randi([0 1], 3, n); % 50/50%
X3 = double(logical(randi([0 3], 5, n))); % 25%/75%


X = [X1;X2;X3];
Y = double(xor(X1(1,:), X1(2,:)));
D = {1:2};

% Set RandStream back to its original one
RandStream.setGlobalStream(oldRs);


end

