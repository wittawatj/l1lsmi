function [Xc, Yc] = kmeansCenters( X, Y, b, seed)
%
% Choose basis centers using the results of K-means.
% If b centers cannot be obtained, randomly choose the rest from the data.
%

[m n] = size(X);

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed', seed);
RandStream.setDefaultStream(rs);          

[YC, Mean] = kmeans(X', b);
YC = YC';
Mean = Mean';
% [YC, Mean] = kmeansclust(X, b, seed);

Nonnans = ~isnan(Mean(1,:));
Xc = Mean(:, Nonnans);
Yc = Y(:, Nonnans);

if size(Xc,2) < b
    rand_index = randperm(n);
    
    restInd = rand_index(1:(b-size(Xc,2)));
    Xc = [Xc, X(:, restInd)];
    Yc = [Yc, Y(:, restInd)];
end

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

