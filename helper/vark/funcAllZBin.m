function [Z, FMat, Ws, Score] = funcAllZBin(X, Y, options)
% 
% Vary z with binary search. 
%
%
[m n ] = size(X);

% depth limit of the binary search
bindepthlimit = myProcessOptions(options, 'bindepthlimit', 13) ;

% difference of the number of features from one step of z to another
% Higher makes the search faster but the results are coarse. 
featuresteps = myProcessOptions(options, 'featuresteps', 1);

% maximum number of z to be varied. The search will stop if the number of
% z's attempted so far reaches this value.
zsteps = myProcessOptions(options, 'zsteps', 20);

% Intializer for W
zinitWfunc = myProcessOptions(options, 'zinitWfunc', @zinitW);
options.zinitWfunc = zinitWfunc;

wranker = myProcessOptions(options, 'wranker', @(w)(wranker_thresh(w, 1e-8)) );
options.wranker = wranker;

% wlearner = function which learns W. f: (X,Y,options) -> [W, fvalue].
wlearner = options.wlearner;

z_min = myProcessOptions(options, 'z_min', 1e-1);
z_max = myProcessOptions(options, 'z_max', 100);

% Data structure for selected features (has m columns)
FMat = false(2,m);
Score = zeros(2,1);

Z = [z_min; z_max];% Keep all z varied
Ws = cell(2,1);

% Try z_min
options.z = z_min ;
options.W0 = zinitWfunc(m, options.z, options.seed);
[WHat, f] = wlearner(X,Y, options);
Score(1) = -f; % ** Assume wlearner the f value of objective function (minimization)
rList = wranker(WHat);
FMat(1, rList) = true;
Ws{1} = WHat;

% Try z_max
options.z = z_max ;
options.W0 = zinitWfunc(m, options.z, options.seed);
[WHat, f] = wlearner(X,Y, options);
Score(2) = -f;
rList = wranker(WHat);
FMat(2, rList) = true;
Ws{2} = WHat;

[Z, FMat, Ws, Score] = binzsearch(1, 2, Z, FMat, Ws, Score, 0, bindepthlimit, ...
    options, X,Y, featuresteps, zsteps);

% sort ZMat according to Z
[Z, SortedZI] = sort(Z, 'ascend');
FMat = FMat(SortedZI, :);
Ws = Ws(SortedZI);
Score = Score(SortedZI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
