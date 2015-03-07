function [ BestRecords, Records ] = fohsic(X, Y, options)
%
% Perform a forward feature selection
% using HSIC as the selection criteria.  
%

[m, n] = size(X);
if nargin < 3
    options = [];
end

% The number of features to select
k = options.k;

% Currently best selected features. Binary m-vector 
bestFV = zeros(1,m);

% Records keep all selected features together with their HSIC values. The
% first column corresponds to HSIC values. Each row is one FV (binary vector).
if m < 100
    Records = zeros( sum( (m-k+1):m ) , m+1);
else
    Records = [];
end

% Keep only the best subset for each size of feature subsets.
BestRecords = zeros(k, m+1);

ri = 1;

for f = 1:k
    % Try adding one more feature
    LRecs = zeros( m-f+1, m+1);
    lri = 1;
    for i=find(~bestFV)
        curFV = bestFV;
        curFV(i) = 1;
        hs = hsic( X(logical(curFV),: ) , Y, options);
        LRecs(lri, : ) = [hs, curFV] ;
        lri = lri + 1;
    end
    
    % Here LRecs should have been filled.
    BestLRecs = sortrows(LRecs , -1);
    if m < 100 
        Records(ri:( ri + size(LRecs,1) -1), : ) = BestLRecs;
    end
    ri = ri + size(LRecs, 1);
    
    % Find best feature subset
    BestLR = BestLRecs(1,:);
    BestRecords(f,:) = BestLR;
    bestFV = BestLR(2:end);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
