function [Wh,f] = undlsmi_cont(X, Y, options)
% 
% Unconstrained DLSMI for continuous output.
% L1-norm must be approximated so that derivative can be calculated.
% 

[m n] = size(X);
if nargin < 3
    options = [];
end

% Normalize both X and Y
X = normdata(X);
Y = normdata(Y);

% Process options
options = processDLSMIoptions(X,Y, options);
v = options.v;
fold = options.fold;
sigmazfactor_list = options.sigmazfactor_list;
sigmayfactor_list = options.sigmayfactor_list;
lsmilambda_list = options.lsmilambda_list;
seed = options.seed;
b = options.b;
winitfunc = options.winitfunc;

% wpenaltyfunc = penalty function for W (typically an approximation of l1)
wpenaltyfunc = myProcessOptions(options, 'wpenaltyfunc', @(w)(l1approx(w,1e-10)));
options.wpenaltyfunc = wpenaltyfunc;

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Basis centers
rand_index = randperm(n);
Xc = X(:, rand_index(1:b));
Yc = Y(:, rand_index(1:b));

%%% Begin DLSMI %%%%%

% Calculate constants (put them in const struct)
const.Xc = Xc;
const.Yc = Yc;

% Gaussian kernel on Y 
medy = meddistance(Y);
% Cell array of Ky's
Kys = arrayfun(@(sig)(kerGaussian(Yc, Y, sig)), ...
    medy*sigmayfactor_list, 'UniformOutput', false); 
const.Kys = Kys;
const.medy = medy;

fun = @(Wx)(funObjNegLSMI_cont(Wx, X, Y, const, options));
funObj = @(Wx)(augmentPenalty(Wx, fun, v, wpenaltyfunc));

% Pick one optimizer without reasons ...
W0 = winitfunc(m);

% Options for optimizer
opt = lbfgsOptions();
[Wh,f] = fminlbfgs(funObj, W0, opt);

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

