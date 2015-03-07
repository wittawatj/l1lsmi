function [X,Y,D] = gen_xor5(n, seed)
% 
% Xor problem. 5 dependent features
% Redundant features are corrupted by bit flip noises.
% Total 20 features.
% 

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


X1 = randi([0 1], 5, n); % 50/50%
X2 = zeros(size(X1));
for i=1:size(X2,1)
    X2(i,:) = X1(i,:);
    flipNoise = ~logical(randi([0 2], 1, n)); % 33% chance of bit flip
    X2(i, flipNoise) = ~X2(i, flipNoise);
end
X3 = double(logical(randi([0 3], 10, n))); % 25%/75% 0/1 bits noises


X = logical([X1;X2;X3]);
Y = mod(sum(X1,1),2);
D = {1:5};

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);


end

