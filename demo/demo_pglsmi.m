function  demo_pglsmi( )
%
% Demonstrate how to use pglsmi (L1-LSMI).
% pg is an internal code for 'Plain gradient'
%
rng(1);
%%%%% Generate a toy dataset
% X is #dim x #sample
% Y is 1 x #sample
[X Y] = gen_plus(400);

%%%%% Some settings
% Number of features to select. Necessary option.
o.k = 2;

% How many restarts ? More restarts of course give better features, but
% slower.
o.ztuner_repeat = 1;

% LSMI cross validation fold
o.fold = 5; 

% Max iterations for one value of z (l1-ball radius)
o.maxIter = 100;

% Internally, pglsmi tries to find z which gives k features.
% But, in case that k is very large, it is difficult to get exact k
% features. So, we may allow some radius.
% 
% If #features_found is between k and k+high_k_radius, then treat as found.
% Put 0 (exact k) here since it is just a demo. 
o.high_k_radius = 0; 

% There are many other options. See the relevant files in pglsmi folder.
% In particular, see the lines with "myProcessOptions".

%%%%% Run pglsmi
S = fs_pglsmi(X, Y, o); % return a struct 
S

% S.F is a logical vector indicating which features are selected.
% Hopefully, we have [1 1 0 0 0 0 0 0 0 0] here. (the first two features 
% should be selected).
S.F

% S.ZT.W returns the actual weights W found using z = S.ZT.z. The final
% objective function value is S.ZT.f.
S.ZT.W

%%%%%%%%%%%%%%%%%%%%
end

function [X Y]=gen_plus(n)
% Simple classification problem.    
% 10 features.
% Y = sign(2*X1 - 3*X2 + noise)
    X = randn(10, n);
    Y = sign(2*X(1,:) - 3*X(2,:) + randn(1,n)/2);
    Y(Y==0) = 1;
end


