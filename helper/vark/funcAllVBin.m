function [V, FMat, Ws, Score] = funcAllVBin(X,Y, options)
% 
% Vary v with binary search. 
%
%
[m n ] = size(X);

% depth limit of the binary search
bindepthlimit = myProcessOptions(options, 'bindepthlimit', 13) ;

% difference of the number of features from one step of v to another
% Higher makes the search faster but the results are coarse. 
featuresteps = myProcessOptions(options, 'featuresteps', 1);

% maximum number of v to be varied. The search will stop if the number of
% v's attempted so far reaches this value.
vsteps = myProcessOptions(options, 'vsteps', 20);

wranker = options.wranker;

% wlearner = function which learns W. f: (X,Y,options) -> [W, fvalue].
wlearner = options.wlearner;

v_min = myProcessOptions(options, 'v_min', 0);
v_max = myProcessOptions(options, 'v_max', 1);

% Data structure for selected features (has m columns)
FMat = false(2,m);
Score = zeros(2,1);

V = [v_min; v_max];% Keep all v varied
Ws = cell(2,1);

% Try v_min
options.v = v_min ;
[WHat, f] = wlearner(X,Y, options);
Score(1) = -f; % ** Assume wlearner the f value of objective function (minimization)
rList = wranker(WHat);
FMat(1, rList) = true;
Ws{1} = WHat;

% Try v_max
options.v = v_max ;
[WHat, f] = wlearner(X,Y, options);
Score(2) = -f;
rList = wranker(WHat);
FMat(2, rList) = true;
Ws{2} = WHat;

[V, FMat, Ws, Score] = binvsearch(1, 2, V, FMat, Ws, Score, 0, bindepthlimit, ...
    options, X,Y, featuresteps,vsteps);

% sort VMat according to V
[V, SortedVI] = sort(V, 'ascend');
FMat = FMat(SortedVI, :);
Ws = Ws(SortedVI);
Score = Score(SortedVI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
