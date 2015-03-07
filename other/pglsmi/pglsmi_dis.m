function [Wh,f, Info] = pglsmi_dis(X, Y, options)
%
% Discrete
% 

[m n] = size(X);
if nargin < 3
    options = [];
end

% Normalize X
X = normdata(X);

[m n ] = size(X);
% maximum number of nonzero features before stopping the iterations
nzthreshold = myProcessOptions(options, 'nzthreshold', 1);

% z = the width of the l1 ball constraint
z = myProcessOptions(options, 'z', 1);


% fold = number of folds to do in cross validation 
fold = myProcessOptions(options, 'fold', 5);

% sigmazfactor_list = list of candidates to be multiplied with pair-wise
% median distance of all Z_i, then used as the Gaussian width parameter for
% Z.
if ~isfield(options, 'sigmazfactor_list')
%     sigmazfactor_list = [1/5, 1/2, 1, 2, 5];
    sigmazfactor_list = [1];
    options.sigmazfactor_list = sigmazfactor_list;
end

% List of candidates for sigmaz which will be directly used (no median
% multiplied). This will be combined with med*sigmazfactor_list and used
% as the candidates in CV.
sigmaz_list = myProcessOptions(options, 'sigmaz_list', [0.5 1 2] );

% lsmilambda_list = list of candidates of LSMI's lambda
lsmilambda_list = myProcessOptions(options, ...
    'lsmilambda_list', [1e-4, 1e-3, 1e-2]);

% seed = seed of randomness
seed =  myProcessOptions(options,   'seed', 1 );  

% Set the RandStream to use the seed
oldRs = RandStream.getGlobalStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setGlobalStream(rs);     


% b = number of basis functions
b = myProcessOptions(options, 'b', min(100, n) );
b = min(b, n);

%
% Number of iterations to do booting CV.
% CV will be done in every iteration of the first (bootingcvs) iterations. 
%
bootingcvs = myProcessOptions(options, 'bootingcvs', 3);

%
% After booting CV, CV will be done in every (cvevery) iterations.
% In the iteration in which no CV is performed, the best parameters are the
% same as the parameters chosen with the latest CV.
%
cvevery = myProcessOptions(options, 'cvevery', 5); 
% (no CV during the line search)


% Progress threshold = threshold on the difference of the objective values 
% of last two iterations
progTol = myProcessOptions(options, 'progTol', 1e-5);

% Optimality threshold = threshold on 2norm of the gradient 
optTol = myProcessOptions(options, 'optTol', 1e-5);

% Maximum iterations to do
maxIter = myProcessOptions(options, 'maxIter', 100);

% Initializer of W
W0 = 1+rand(m,1);
W0 = z*W0/sum(W0);

W0 = myProcessOptions(options, 'W0', W0 );

pfunc = @(w)(projectPositiveL1(w, z));
% pfunc = @(w)(projectL1(w, z));

% Constraint projection function. By default, project to positive l1-ball.
conprojFunc = myProcessOptions(options, 'conprojFunc', pfunc);

% Step size = 1/sqrt(t) where t is the number of iteration. 
% Used in plaingradient.m
stepsizeFunc = myProcessOptions(options, 'stepsizeFunc', @(info)(1/sqrt(info.k)));
% stepsizeFunc = myProcessOptions(options, 'stepsizeFunc', @bbstepfunc);

W0 = conprojFunc(W0);
% W0T = W0'

% Gather all options into options struct
options.z = z;
options.fold = fold;
options.sigmaz_list = sigmaz_list;
options.lsmilambda_list = lsmilambda_list;
options.seed = seed;
options.b = b;
options.nzthreshold = nzthreshold;
options.bootingcvs = bootingcvs;
options.cvevery = cvevery;
options.progTol = progTol;
options.optTol = optTol;
options.maxIter = maxIter;
options.W0 = W0;
options.conprojFunc = conprojFunc;
options.stepsizeFunc = stepsizeFunc;

% Basis centers
rand_index = randperm(n);
Xc = X(:, rand_index(1:b));
Yc = Y(:, rand_index(1:b));

%%% Begin PGLSMI %%%%%

% Calculate constants (put them in const struct)
const.Xc = Xc;
const.Yc = Yc;
const.Ky = kerDelta(Yc, Y);

refInfo = Ref();
funObj =  @(Wx, ref)(funObjNegLSMI_dis(Wx, X, Y, const, options, ref));
[ Wh, Info ] = plaingradient(W0, funObj, options, refInfo);

f = Info.F(end);

% Set RandStream back to its original one
RandStream.setGlobalStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

