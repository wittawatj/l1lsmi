function [Wh, f, Info] = pghsic_dis(X, Y, options)
%
% Discrete case
% 

[m n] = size(X);
if nargin < 3
    options = [];
end

% Normalize X 
X = normdata(X);

% maximum number of nonzero features before stopping the iterations
nzthreshold = myProcessOptions(options, 'nzthreshold', 1);

% z = the width of the l1 ball constraint
z = myProcessOptions(options, 'z', 1);

% seed = seed of randomness
seed =  myProcessOptions(options,   'seed', 1 );  

% Initializer of W
W0 = 1+rand(m,1);
W0 = z*W0/sum(W0);

W0 = myProcessOptions(options, 'W0', W0 );

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
medheuevery = myProcessOptions(options, 'medheuevery', 5);

optTol = myProcessOptions(options, 'optTol', 1e-5);
progTol = myProcessOptions(options, 'progTol', 1e-5);
maxIter = myProcessOptions(options, 'maxIter', 100);

pfunc = @(w)(projectPositiveL1(w, z));
% pfunc = @(w)(projectL1(w, z));
conprojFunc = myProcessOptions(options, 'conprojFunc', pfunc);

stepsizeFunc = myProcessOptions(options, 'stepsizeFunc', @(info)(1/sqrt(info.k)));
% stepsizeFunc = myProcessOptions(options, 'stepsizeFunc', @bbstepfunc);

W0 = conprojFunc(W0);

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Gather all options into options struct
options.nzthreshold = nzthreshold;
options.z = z;
options.seed = seed;
options.W0 = W0;
options.bootingmedheu = bootingmedheu;
options.medheuevery = medheuevery;
options.optTol = optTol;
options.progTol = progTol;
options.maxIter = maxIter;
options.conprojFunc = conprojFunc;
options.stepsizeFunc = stepsizeFunc;

%%% Begin DHSIC %%%%%

% Delta kernel on Y 
L = kerDelta(Y, Y);
LH = bsxfun(@plus, L, -mean(L,2));
HLH = bsxfun(@plus, LH, -mean(LH,1));


funObj = @(Wx, refInfo)(funObjNegHSIC( Wx, X, LH, HLH, options, refInfo));
refInfo = Ref();
[ Wh, Info ] = plaingradient(W0, funObj, options, refInfo);

f = Info.F(end);

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

