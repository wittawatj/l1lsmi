function [X,Y,D] = gen_xor152(n, seed)
% 
% Xor problem. Total 152 dimensions.
% 

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

X1 = randi([0 1], 2, n); % 50/50%
X2 = randi([0 1], 75, n); % 50/50%
X3 = double(logical(randi([0 3], 75, n))); % 25%/75%

X = [X1;X2;X3];
Y = xor(X1(1,:), X1(2,:));
D = {1:2};

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

