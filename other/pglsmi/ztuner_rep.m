function [ZT, ZTLogs] = ztuner_rep(X, Y, options)
% 
% Repeatedly do ztuner_...
% 

[m n] = size(X);
% ztuner function
ztuner =  options.ztuner;

% 
seed = myProcessOptions(options,'seed', 1);

% Set the RandStream to use the seed
oldRs = RandStream.getGlobalStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setGlobalStream(rs);     

% Number of restarts
% Changing the default value here -> also change the divisor in fs_pglsmi,
% fs_pghsic.
ztuner_repeat = myProcessOptions(options, 'ztuner_repeat', 5);

seedlist = randi([1e4, 1e7], 1, ztuner_repeat);

% Set RandStream back to its original one
RandStream.setGlobalStream(oldRs);

ZTLogs = cell(1,length(seedlist));
ZTs = [];

for i=1:length(seedlist)
    seed = seedlist(i);
    options.seed = seed;
    fprintf('%s: seed: %.3g\n', mfilename, seed);
    [ZT, ZTLog]= ztuner(X, Y, options); % call vtuner func
    ZTLogs{i} = ZTLog;
    ZTs = [ZTs, ZT];
end

k = options.k;
ZT = bestZT(ZTs, k);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

