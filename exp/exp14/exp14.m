function exp14(data, fs_func, trial)
%
% For real data experiment. For small datasets < 1000 features.
% Limit maxIter. Do many restarts like exp13
%
maxn = 400;


if ischar(data)
    % data is string. Assume it is the path name for real data.
    load(data);
    [ X, Y] = shuffler(X, Y, maxn, trial); 
    m = size(X,1);
    k = realK(m); % number of features to select
else
    error('data must be string (dataset path)');
end

[m n] = size(X);


% Options: L1
o.seed = trial;
o.wranker = @(w)(wranker_thresh(w,1e-8));
o.v_min = 1e-4; % for vtuner_seq
o.v_max = 1; % for vtuner_rseq
o.fold = 5; %%%
o.b = min(100,n); 
o.k = k;
o.initWs = [ones(m,1), 2*rand(m,1)]; % for vtuner_rep
o.lsmilambda_list = logspace(-3,1,5); % 

% Options: DLSMI
o.sigmazfactor_list = [1/2, 1, 2]; %%%
o.sigmaz_list = [1 2 (1/sqrt(2))*[1/5, 1]*meddistance(X)]; %%%
o.sigmayfactor_list = [1];
o.bootingcvs = 3;
o.cvevery = 5;

% Options: DHSIC
o.bootingmedheu = o.bootingcvs;
o.medheuevery = o.cvevery;

% Options: PGLSMI
o.ztuner_repeat = 20; %%%
o.z_min = 1e-1;
o.zsteps = 15;
o.zbinsteps = 10;
o.zinitWfunc = @zinitW;
o.maxIter = 20;  %%%

metaexp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end 

