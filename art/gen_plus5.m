function [ X,Y,D] = gen_plus5( n, seed)
% 


% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

Xtrue = [2*randn(2,n) ; 3*randn(3,n)];
Xfalse = randn(15,n);

X = [Xtrue;Xfalse];
Y = sum(Xtrue,1) + randn(1,n);
D = {1:size(Xtrue,1)};

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%
end

