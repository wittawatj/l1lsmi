function [Wh,f, Info] = lasslsmi_cont(X, Y, options)
%
% Continuous case.
% 

[m n] = size(X);
if nargin < 3
    options = [];
end
options.initL = 1/n;

% Normalize both X and Y
X = normdata(X);
Y = normdata(Y);

[m n ] = size(X);
% maximum number of nonzero features before stopping the iterations
nzthreshold = myProcessOptions(options, 'nzthreshold', 1);

% z = the width of the l1 ball constraint
z = myProcessOptions(options, 'z', 1);


% fold = number of folds to do in cross validation 
fold = myProcessOptions(options, 'fold', 2);

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
sigmaz_list = myProcessOptions(options, 'sigmaz_list', (1/sqrt(2))*[1 2 5 10] );

% lsmilambda_list = list of candidates of LSMI's lambda
lsmilambda_list = myProcessOptions(options, ...
    'lsmilambda_list', [1e-4, 1e-3, 1e-2]);

% seed = seed of randomness
seed =  myProcessOptions(options,   'seed', 1 );  

% l2 regularization parameter
rho = myProcessOptions(options, 'rho', 0);

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


% b = number of basis functions
b = myProcessOptions(options, 'b', min(100, n) );

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
cvevery = myProcessOptions(options, 'cvevery', 0);

optTol = myProcessOptions(options, 'optTol', 1e-5);

progTol = myProcessOptions(options, 'progTol', 1e-4);

maxIter = myProcessOptions(options, 'maxIter', 100);

% Initializer of W
W0 = 1+rand(m,1);
W0 = z*W0/sum(W0);

W0 = myProcessOptions(options, 'W0', W0 );

pfunc = @(w)(projectPositiveL1(w, z));
% pfunc = @(w)(projectL1(w, z));
conprojFunc = myProcessOptions(options, 'conprojFunc', pfunc);

W0 = conprojFunc(W0);

% Gather all options into options struct
options.z = z;
options.fold = fold;
options.sigmaz_list = sigmaz_list;
options.lsmilambda_list = lsmilambda_list;
options.seed = seed;
options.rho = rho;
options.b = b;
options.nzthreshold = nzthreshold;
options.bootingcvs = bootingcvs;
options.cvevery = cvevery;
options.optTol = optTol;
options.progTol = progTol;
options.maxIter = maxIter;
options.W0 = W0;
options.conprojFunc = conprojFunc;

% Basis centers
rand_index = randperm(n);
Xc = X(:, rand_index(1:b));
Yc = Y(:, rand_index(1:b));

%%% Begin LASSLSMI %%%%%

% Calculate constants (put them in const struct)
const.Xc = Xc;
const.Yc = Yc;

funObj =  @(Wx, t)(fobjLassLSMI_cont(Wx, X, Y, const, options));
[ Wh, Info ] = lassploresolver(W0, funObj, options);

f = Info.F(end);

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

