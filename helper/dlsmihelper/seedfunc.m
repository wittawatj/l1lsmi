function Ws = seedfunc( X,Y, wlearner, options)
% 
% Try to learn W many times by changing only the seed.
% 

% seedlist = list of seed values to try 
seedlist = myProcessOptions(options,'seedlist', 1:15);
m = size(X,1);
Ws = zeros(m, length(seedlist));
for i=1:length(seedlist)
    seed = seedlist(i);
    options.seed = seed;
    W = wlearner(X,Y,options);
    Ws(:,i) = W;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

