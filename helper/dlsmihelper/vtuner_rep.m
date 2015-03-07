function [VT, VTLogs] = vtuner_rep(X, Y, options)
% 
% Repeatedly do vtuner_...
% 

[m n] = size(X);
% vtuner function
vtuner =  options.vtuner;

% 
seed = myProcessOptions(options,'seed', 1);

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% Initializer of W. The number of columns is used as the number of repeats.
% ones(m,1) is a good heuristic for initializing W.
initWs = myProcessOptions(options, 'initWs', [ones(m,1), rand(m,4)] );
vtuner_repeat = size(initWs,2);

seedlist = randi([1e4, 1e7], 1, vtuner_repeat);

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

VTLogs = cell(1,length(seedlist));
VTs = [];

for i=1:length(seedlist)
    seed = seedlist(i);
    options.seed = seed;
    options.W0 = initWs(:,i);
    fprintf('%s: seed: %.3g\n', mfilename, seed);
    [VT, VTLog]= vtuner(X, Y, options); % call vtuner func
    VTLogs{i} = VTLog;
    VTs = [VTs, VT];
end

k = options.k;
VT = bestVT(VTs, k);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

