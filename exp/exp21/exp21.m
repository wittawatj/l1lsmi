function exp21(data, fs_func, trial)
%
% For real data experiment. For huge datasets with more than 2000 features.
%  Select 20 features. Following exp20, since repeating a lot does not
%  improve the performance of pglsmi that much, we change our focus to
%  increasing the number of candidates for parameters.
%
maxn = 400;
k = 20; % number of features to select

if ischar(data)
    % data is string. Assume it is the path name for real data.
    load(data);
    [ X, Y] = shuffler(X, Y, maxn, trial); 
    
else
    error('data must be string (dataset path)');
end

[m n] = size(X);


% Options: L1
o.seed = trial;
o.wranker = @(w)(wranker_thresh(w,1e-8));
o.v_min = 1e-4; % for vtuner_seq
o.v_max = 1; % for vtuner_rseq
o.fold = 5; 
o.b = min(200,n); %%
o.k = k;
o.initWs = [ones(m,1), 2*rand(m,1)]; % for vtuner_rep
o.lsmilambda_list = logspace(-3,1,5); %%

% Options: DLSMI
o.sigmazfactor_list = [1/10, 1/5, 1/2, 1, 2, 5, 10]; %%%
o.sigmaz_list = linspace(0.5, 4, 5);
o.sigmayfactor_list = [1];
o.bootingcvs = 3;
o.cvevery = 5;

% Options: DHSIC
o.bootingmedheu = o.bootingcvs;
o.medheuevery = o.cvevery;

% Options: PGLSMI
o.ztuner_repeat = 20; 
o.z_min = 1e-3; %%%
o.zsteps = 40;
o.zbinsteps = 30;
o.zinitWfunc = @zinitW;
o.maxIter = 60;  %%%
o.progTol = 1e-5; %%
o.optTol = 1e-5; %%
% For ztuner_seq_radius
o.high_k_radius = 20;
o.low_k_radius = 0;

metaexp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end 

