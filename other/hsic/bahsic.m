function [ BestRecords, Records ] = bahsic(X, Y, options)
%
% Perform a backward elmination feature selection
% using HSIC as the selection criteria.  
%
% The algorithm follows Algorithm 1 described in the paper
% ``Supervised Feature Selection via Dependence Estimation''
% except that each iteration removes only one feature (not 10%
% of the current number of features as in the paper).
% The Gaussian width is adapted in each iteration as described in
% the paper.
%

[m, n] = size(X);
if nargin < 3
    options = [];
end

% The number of features to select
k = options.k;

% Currently best selected features. Binary m-vector 
bestFV = ones(1,m);

% Records keep all selected features together with their HSIC values. The
% first column corresponds to HSIC values. Each row is one FV (binary vector).
if m < 100
    Records = zeros( sum( (k+1):m ) , m+1);
end

% Keep only the best subset for each size of feature subsets.
BestRecords = zeros(m-k+1, m+1);
BestRecords(1,:) = [hsic(X,Y,options) , ones(1,m) ];

ri = 1;
% Start backward search
for f = (m-1):-1:k % f is the number of features to consider
    
    LRecs = zeros(f+1, m+1);
    lri = 1;
    % Try removing one more feature
    for i=find(bestFV)
        curFV = bestFV;
        curFV(i) = 0; % Remove feature i
        hs = hsic( X(logical(curFV),: ) , Y, options);
        LRecs(lri, : ) = [hs, curFV] ;
        lri = lri + 1;
    end
    
    % Here LRecs should have been filled.
    BestLRecs = sortrows(LRecs, -1); % sort HSIC value descending order
    if m < 100
        Records(ri:(ri+size(LRecs,1) - 1 ) , :) = BestLRecs;
    end
    ri = ri + size(LRecs, 1);
    
    % Find best feature subset
    BestLR = BestLRecs(1,:);
    BestRecords(m-f+1, :) = BestLR;
    bestFV = BestLR(2:end);
end

if m >= 100 
    Records = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
