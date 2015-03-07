function [WHat, options,logs] = HSICL1General(X,Y, options)
%
% Find a projection matrix W which maximizes HSIC criterion.
% A grouplasso penalty is placed on the projection matrix so that
% it has column-level sparseness. 
% Use Mark Schmidt's toolbox for the optimization.
% 
% Apr 14, 2011 Wittawat Jitkrittum
%

if nargin<2
  error('number of input arguments is not enough!!!')
end

[m n] =size(X);
ny=size(Y,2);

if n ~= ny
  error('X and Y must have the same number of samples!!!')
end;

if nargin < 3
    options = [];
end

% Regularization parameter (control the column sparseness of W)
v = myProcessOptions(options, 'v', 0.1);

% Gaussian width for Y (use pairwise median distance by default)
meddisty = meddistance( double(Y') );
sigmay = myProcessOptions(options, 'sigmay', meddisty);

% If true, then Delta kernel is used on Y (for classification problems).
deltakernel = myProcessOptions(options, 'deltakernel' , size(Y,1) == 1 && length(unique(Y)) <= 26 ); 

% If true, then each label is transformed into a label vector.
% Then, linear kernel is applied (for classification problems).
% If deltakernel and labelvectorized are both false, Gaussian kernel
% is used on Y (regression). 
% If they are both true, then it is the same as deltakernel=false,
% labelvectorized=true. 
labelvectorized = myProcessOptions(options, 'labelvectorized' , 0);
if size(Y,1) > 1
    deltakernel = 0;
    labelvectorized = 0;
end

% boolean value whether to normalize X  so that the data is center at
% 0 and have unit variance
normalizex= myProcessOptions(options, 'normalizex', true) ; 

% Rows of W
d = myProcessOptions(options,   'd', ceil(2*m/3)  ); 

seed =  myProcessOptions(options,   'seed', 1 );   % seed is default to 1 to be deterministic

% Set the RandStream to use the seed
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Initial W
if ~isfield(options, 'initW')
    if m <= 500
        initW = orthoInit(d,m); 
    else
        initW = rand(d,m);
    end
    
else
    initW = options.initW;
end
d = size(initW,1);

iterationlimit = myProcessOptions(options, 'iterationlimit' , 100);
optTol = myProcessOptions(options, 'optTol',10^-6);
maxIter = myProcessOptions(options,'maxIter', 100);
progTol = myProcessOptions(options, 'progTol', 10^-7);

% Function to calculate negative LSMI
neghsicfunc = myProcessOptions(options, 'neghsicfunc', @negativeHSIC);

options.v = v;
options.sigmay = sigmay;
options.deltakernel = deltakernel;
options.labelvectorized  = labelvectorized ;
options.normalizex =  normalizex;
options.d = d;
options.seed = seed;
options.initW = initW;
options.iterationlimit = iterationlimit;
options.optTol = optTol;
options.maxIter = maxIter;
options.progTol = progTol;
options.neghsicfunc = neghsicfunc;
options

if normalizex 
	X = diag(1./std(X , 0 , 2)) * (X - repmat( mean(X , 2), 1 , n) ) ;
end

%%%%%% Begin algorithm %%%%%


W = initW;

if labelvectorized
    YY = labelVectorize(Y);
    L = calGramLinear(YY);
else
    if deltakernel 
        L = calGramDelta(Y);
    else
        L = calGramGaussian(Y, sigmay);
    end
end

LH = L - repmat(mean(L,2),1,n);

calc.iterationnum = 1;
calc.LH = LH; % Constant throughout the algorithm.

funObj = @(Wv, signal)(vecNegativeHSIC(Wv , X, calc, options, signal) );
lambda = ones(m,1)*v;
groups = reshape(repmat(1:m, d, 1), 1, d*m)';
wvInit = W(:);


clear vecNegativeHSIC
[w,logs] = L1GeneralGroup_L12(funObj, wvInit ,lambda ,groups,options);
%w = L1GeneralGroup_SoftThresh(funObj, wvInit ,lambda ,groups,options);
clear vecNegativeHSIC % to reinitialize the persistent variables in vecNegativeHSIC
WHat = reshape(w, d, m);

% Reshape W and its grad in each iteration to its matrix form
for i=1:length(logs)
    logs(i).x = reshape(logs(i).x, d,m);
    logs(i).grad = reshape(logs(i).grad, d,m);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

