function [YC, Mean]= kmeansclust(X, Y0, seed)
%
% Perform k-means clustering on data X (d x n).
% One column in X is one instance.
% Y0 can be 1 x n initial cluster assignment, or
% can be just integer scalar for desired number of clusters.
%
error('Use Matlab''s kmeans instead');

[d n] = size(X);
if nargin < 3
    seed = 1;
end

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Find initial cluster assignment Y0
c = 0; % number of classes
if isscalar(Y0)
    c = Y0;
    Y0 = randi([1 c], 1, n);    
else
    c = length(unique(Y0));
end

if size(Y0,2) ~= n
    error('Y0 must have the same size as X');
end

YC = Y0;
X2 = repmat(sum(X.^2,1),c,1);
% Y in the previous iteration.
PrevY = [];
iterations = 0;
% Begin k-means
while true 
    % Make Y an indicator matrix (c x n) (sparse).
    % last two arguments are important to keep Y to be c x n.
    % It is possible that no instances are assigned to some classes.
    % That will make the rows of Y smaller than c
    Y = sparse(YC, 1:n, 1,c,n); 
    
    % d x c matrix of means for each class
    Mean = (X*Y')*sparse(1:c, 1:c, 1./sum(Y,2));
    % 2-norm^2 distance matrix D (c x n)
    D = repmat(sum(Mean'.^2,2),1,n) -2*Mean'*X + X2;
    % Find closest cluster mean for each instance in X
    [V, YC] = min(D, [], 1);
    
    % Convergence check
    if ~isempty(PrevY) && sum(sum(abs(PrevY - Y))) <= 0 
        break;
    end
    % iteration limit
    if iterations >= 50
        fprintf('K-means procedure exceeds iteration limit.\n');
        break;
    end
    PrevY = Y;
    iterations = iterations+1;
    
end
fprintf('K-means finished in %d iterations\n', iterations);

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end