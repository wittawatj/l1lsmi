function [X,Y,D] = gen_xor3(n, seed)
% 
% Xor 3 problem. 
% 

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


X1 = randi([0 1], 3, n); % 50/50%
X2 = randi([0 1], 2, n); % 50/50%
X3 = double(logical(randi([0 3], 5, n))); % 25%/75%


X = [X1;X2;X3];
Y = mod(sum(X1,1),2);
D = {1:3};

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);


end

