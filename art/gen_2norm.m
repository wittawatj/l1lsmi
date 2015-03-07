function [ X,Y,D] = gen_2norm( n, seed)
% 
% Regression
%
t = 3;

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

Xtrue = [randn(t,n)];
Xfalse = 6*rand(20-t,n)-3;

X = [Xtrue; Xfalse];
Y = -sum(Xtrue.^2,1) ;
D = {1:t};

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%
end

