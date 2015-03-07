function [SW] = wlsmi_cont( X, Y, options )
%
% LSMI in which Gaussian basis function of X has m widths where m is the
% number of features. l1-penalty is imposed on these widths to make them
% sparse for feature selection. 
% 
%   
% Initialize W0
% For each (lambda, sigma_y) candidate:
%   Optimize W until converged using (lambda, sigma_y)
%   Calculate LSMI CV score 
%   Restart
% Find (W, lambda, sigma_y) with the best CV score


if nargin < 3
    options = [];
end

[m n] = size(X);

% Normalize both X and Y
X = normdata(X);
Y = normdata(Y);

% maximum number of nonzero features before stopping the iterations
nzthreshold = myProcessOptions(options, 'nzthreshold', 0);

% W's l1-regularization parameter
v = myProcessOptions(options, 'v', 0.05);

% fold = number of folds to do in cross validation 
fold = myProcessOptions(options, 'fold', 2);

% lsmilambda_list = list of candidates of LSMI's lambda
lsmilambda_list = myProcessOptions(options, ...
    'lsmilambda_list', [1e-4]);

sigmayfactor_list = myProcessOptions(options, ...
    'sigmayfactor_list', [ 1]);

% seed = seed of randomness
seed =  myProcessOptions(options,   'seed', 1 );  

% Initializer of W
W0 = myProcessOptions(options, 'W0',  randInit(m,seed) );

% b = number of basis functions
b = myProcessOptions(options, 'b', min(100, n) );
b = min(b,n);

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Basis centers
rand_index = randperm(n);
Xc = X(:, rand_index(1:b));
Yc = Y(:, rand_index(1:b));

%%%%%%%%% Begin WLSMI %%%%%%%%%%%%
medy = meddistance(Y);
Kys = arrayfun(@(sig)(kerGaussian(Yc, Y, sig)), ...
    medy*sigmayfactor_list, 'UniformOutput', false); 

% CV to find best sigmayfactor, lsmilambda
CVErr = zeros(length(Kys), length(lsmilambda_list));
% Learned W for each combination of parameters
CVW = cell(length(Kys), length(lsmilambda_list));

% Options for optimizer
opt.optTol = 1e-5;
opt.progTol = 1e-5;
opt.maxIter = 150;
opt.order = -1; %lbfgs
opt.nzthreshold = nzthreshold;

I = strapartregression(n, fold, seed);

for syi = 1:length(Kys)
    Ky = Kys{syi};

    for lsmilambda_i = 1:length(lsmilambda_list) %lsmilambda
        lsmilambda = lsmilambda_list(lsmilambda_i);

        calc.Xc = Xc;
        calc.Ky = Ky;
        calc.lsmilambda = lsmilambda;
        funObj = @(Wx)(fobjwlsmi( Wx, X, Y, calc, options ));

        % Optimize W    
        W = L1GeneralProjection(funObj,W0,v*ones(m,1), opt);

        CVW{syi, lsmilambda_i} = W;
        Z = bsxfun(@times, W, X);    
        Zc = bsxfun(@times, W, Xc);    
        KzPre = kerPreGaussian(Zc, Z);
        Kz = exp(KzPre);

        Errs = zeros(fold ,1);
        for fold_i = 1:fold
            teI = I(fold_i,:);
            trI = ~teI;                

            KyTr = Ky(:,trI);
            KyTe = Ky(:,teI);
            KzTr = Kz(:,trI);
            KzTe = Kz(:,teI);

            HTr = calBigH(KyTr, KzTr);
            HTe = calBigH(KyTe, KzTe);
            hTr = calSmallh(KyTr, KzTr);
            hTe = calSmallh(KyTe, KzTe);

            AlphaTr = (HTr + lsmilambda * eye(b) ) \ hTr;
            Errs(fold_i) = 0.5 * AlphaTr'* HTe * AlphaTr - hTe' * AlphaTr;
        end
        CVErr(syi, lsmilambda_i) = mean(Errs);

    end %lsmilambda
end

clear Ky Kz lsmilambda W

% Determine the best parameters
[minerr, i] = min(CVErr(:));
[bsyi, bli] = ind2sub(size(CVErr), i);

BKy = Kys{bsyi};
best_lsmilambda = lsmilambda_list(bli);

% Optimize W with the best parameters
Wh = CVW{bsyi, bli};
bcalc.Xc = Xc;
bcalc.Ky = BKy;
bcalc.lsmilambda = best_lsmilambda;
nlsmi = fobjwlsmi( Wh, X, Y, bcalc, options );


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);


SW.Wh = Wh;
SW.nlsmi = nlsmi;
SW.CVW = CVW;
SW.CVErr = CVErr;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


function h = calSmallh(Phiy, Phiz)
    h = mean(Phiy .* Phiz , 2) ;
end

function H = calBigH(Phiy, Phiz)
    n = size(Phiz, 2);
    H = (Phiy * Phiy') .* (Phiz * Phiz') ./ (n^2);
end
