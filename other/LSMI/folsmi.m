function [ BestRecords, Records ] = folsmi( X, Y, options )
%
% Perform forward sequential search using LSMI
% as feature selection criterion.
%

[m n] = size(X);
if nargin < 3
    options = [];
end

% The number of features to select
k = options.k;

sigmaxfactor_list = myProcessOptions(options, 'sigmaxfactor_list', ...
    [1/5, 1/2, 1, 2, 5]);
lsmilambda_list = myProcessOptions(options, 'lsmilambda_list', [1e-4]);
seed =  myProcessOptions(options,   'seed', 1 );  
% b = number of basis functions
b = myProcessOptions(options, 'b', min(200, n) );
deltakernel = myProcessOptions(options, 'deltakernel', isclassification(X,Y));
% fold = number of folds to do in cross validation 
fold = myProcessOptions(options, 'fold', 2);

if deltakernel
    % Normalize X 
    X = normdata(X);
else
    % Normalize both X and Y
    X = normdata(X);
    Y = normdata(Y);
end

options.deltakernel = deltakernel;
options.sigmaxfactor_list = sigmaxfactor_list;
options.lsmilambda_list = lsmilambda_list;
options.b = b;
options.fold = fold;

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Start forward sequential search

% Currently best selected features. Binary m-vector 
bestFV = zeros(1,m);

% Records keep all selected features together with their LSMI values. The
% first column corresponds to LSMI values. Each row is one FV (binary vector).
if m < 100
    Records = zeros( sum( (m-k+1):m ) , m+1);
else
    Records = [];
end

% Keep only the best subset for each size of feature subsets.
BestRecords = zeros(k, m+1);

ri = 1;
options.lambda_list = lsmilambda_list;
for f = 1:k
    % Try adding one more feature
    LRecs = zeros( m-f+1, m+1);
    lri = 1;
    for i =find(~bestFV)
        curFV = bestFV;        
        curFV(i) = 1;
        
        Xr = X(logical(curFV),: );
        med = meddistance(Xr);
        options.sigma_list = med*sigmaxfactor_list;
        
        MIh = LSMI(Xr ,Y,options); 
        LRecs(lri,:) = [MIh curFV];
        lri = lri+1;
        
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

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

