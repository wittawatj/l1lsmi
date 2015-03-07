function [Wh,f, infoLog] = dlsmi_dis(X, Y, options)
% 
% 

[m n] = size(X);
if nargin < 3
    options = [];
end

% Normalize X 
X = normdata(X);

% Process options
options = processDLSMIoptions(X,Y, options);
v = options.v;
fold = options.fold;
sigmazfactor_list = options.sigmazfactor_list;
lsmilambda_list = options.lsmilambda_list;
seed = options.seed;
b = options.b;
nzthreshold = options.nzthreshold;
threshold = options.threshold;

% Initializer of W
W0 = myProcessOptions(options, 'W0',  randInit(m,seed) );

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Basis centers
kmeanscenters = myProcessOptions(options, 'kmeanscenters', false);
if kmeanscenters
    [Xc, Yc] = kmeansCenters( X, Y, b, seed);
else
    rand_index = randperm(n);
    Xc = X(:, rand_index(1:b));
    Yc = Y(:, rand_index(1:b));
end

%%% Begin DLSMI %%%%%

% Calculate constants (put them in const struct)
const.Xc = Xc;
const.Yc = Yc;
const.Ky = kerDelta(Yc, Y);
funObj = @(Wx, refInfo)(funObjNegLSMI_dis(Wx, X, Y, const, options, refInfo));

% Options for optimizer
opt.optTol = options.optTol;
opt.progTol = options.progTol;
opt.maxIter = options.maxIter;
opt.order = options.order;
opt.nzthreshold = nzthreshold;
opt.threshold = threshold;

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

