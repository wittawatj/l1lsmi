function [op] = processDLSMIoptions(X,Y,options)
% 
% Process common options in DLSMI.
% 

[m n ] = size(X);
% maximum number of nonzero features before stopping the iterations
nzthreshold = myProcessOptions(options, 'nzthreshold', 1);

% v = Diagonal W's l1 regularization parameter 
v = myProcessOptions(options, 'v', 0.1);

% fold = number of folds to do in cross validation 
fold = myProcessOptions(options, 'fold', 2);

% sigmazfactor_list = list of candidates to be multiplied with pair-wise
% median distance of all Z_i, then used as the Gaussian width parameter for
% Z.
if ~isfield(options, 'sigmazfactor_list')
    sigmazfactor_list = [1/5, 1/2, 1, 2, 5];
    options.sigmazfactor_list = sigmazfactor_list;
end

% List of candidates for sigmaz which will be directly used (no median
% multiplied). This will be combined with med*sigmazfactor_list and used
% as the candidates in CV.
sigmaz_list = myProcessOptions(options, 'sigmaz_list', (1/sqrt(2))*[1 2] );


% sigmayfactor_list = list of candidates to to be multiplied with pair-wise
% median distance of all Y_i, then used as the Gaussian width parameter for
% Y. This is used only when Gaussian kernel is used on Y (regression
% problems).
sigmayfactor_list = myProcessOptions(options, ...
    'sigmayfactor_list', [ 1/2, 1, 2 ]);

% lsmilambda_list = list of candidates of LSMI's lambda
lsmilambda_list = myProcessOptions(options, ...
    'lsmilambda_list', [1e-4, 1e-3, 1e-2]);

% seed = seed of randomness
seed =  myProcessOptions(options,   'seed', 1 );  

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

progTol = myProcessOptions(options, 'progTol', 1e-5);

maxIter = myProcessOptions(options, 'maxIter', 150);

order = myProcessOptions(options, 'order', -1);

% Maximum magnitude (?) to be treated as nonzero by the Mark's
% optimizer.
threshold = myProcessOptions(options, 'threshold', 1e-4);

% Gather all options into options struct
options.v = v;
options.fold = fold;
options.sigmaz_list = sigmaz_list;
options.sigmayfactor_list = sigmayfactor_list;
options.lsmilambda_list = lsmilambda_list;
options.seed = seed;
options.b = b;
options.nzthreshold = nzthreshold;
options.bootingcvs = bootingcvs;
options.cvevery = cvevery;
options.optTol = optTol;
options.progTol = progTol;
options.maxIter = maxIter;
options.order = order;
options.threshold = threshold;
op = options;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

