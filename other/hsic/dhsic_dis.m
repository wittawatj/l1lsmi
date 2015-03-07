function [Wh, f, infoLog] = dhsic_dis(X, Y, options)
%
% Discrete output case.
% 

[m n] = size(X);
if nargin < 3
    options = [];
end

% Normalize X 
X = normdata(X);

% maximum number of nonzero features before stopping the iterations
nzthreshold = myProcessOptions(options, 'nzthreshold', 1);

% Process options
% v = Diagonal W's l1 regularization parameter 
v = myProcessOptions(options, 'v', 0.1);

% seed = seed of randomness
seed =  myProcessOptions(options,   'seed', 1 );  

% Initializer of W
W0 = myProcessOptions(options, 'W0',  randInit(m,seed) );

%
% Number of iterations to do booting median heuristic.
% Median heuristic will be used in every iteration of the first (bootingmedheu) iterations. 
%
bootingmedheu = myProcessOptions(options, 'bootingmedheu', 3);

%
% After booting median heuristic, median heuristic will be use 
% in every (medheuevery) iterations.
% In the iteration in which no heuristic is performed, the latest one is
% used.
%
medheuevery = myProcessOptions(options, 'medheuevery', 0);

optTol = myProcessOptions(options, 'optTol', 1e-5);

progTol = myProcessOptions(options, 'progTol', 1e-5);

maxIter = myProcessOptions(options, 'maxIter', 150);

order = myProcessOptions(options, 'order', -1);

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Gather all options into options struct
options.v = v;
options.bootingmedheu = bootingmedheu;
options.medheuevery = medheuevery;

%%% Begin DHSIC %%%%%

% Delta kernel on Y 
L = kerDelta(Y, Y);
LH = bsxfun(@plus, L, -mean(L,2));
HLH = bsxfun(@plus, LH, -mean(LH,1));

funObj = @(Wx, refInfo)(funObjNegHSIC( Wx, X, LH, HLH, options, refInfo));

% Options for optimizer
opt.optTol = optTol;
opt.progTol = progTol;
opt.maxIter = maxIter;
opt.order = order;
opt.nzthreshold = nzthreshold;

refInfo = Ref();
[Wh, fEvals, f] = L1GeneralProjection_nuke(funObj,W0,v*ones(m,1), opt, refInfo);
% [Wh] = L1General2_OPG(funObj,W0, v*ones(m,1) , options);
% [Wh, f] = L1General2_TMP(funObj,W0, v*ones(m,1) , opt);
% [Wh] = L1General2_BBSG(funObj,W0, v*ones(m,1) , options);
% [Wh] = L1General2_DSST(funObj,W0, v*ones(m,1) , options);
% [Wh] = L1General2_PSSas(funObj,W0, v*ones(m,1), opt);
% [Wh] = L1General2_AS(funObj,W0, v*ones(m,1) , options);

infoLog = refInfo.obj;
infoLog.G = [infoLog.G{:}];
infoLog.F = [infoLog.F{:}];
infoLog.W = [infoLog.W{:}];
infoLog.T = [infoLog.T{:}];

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

