function [ X,Y,D] = gen_plus( n, seed)
% 


% Set the RandStream to use the seed
oldRs = RandStream.getGlobalStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setGlobalStream(rs);          


Xtrue = [2*randn(1,n) ; 3*randn(1,n)];
Xfalse = randn(8,n);

X = [Xtrue;Xfalse];
Y = sum(Xtrue(1:2,:),1);
D = {1:2};

% Set RandStream back to its original one
RandStream.setGlobalStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%
end

