function [ X,Y,D] = gen_plusc( n, seed)
% 
% Classification
%

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

Xtrue = [2*randn(1,n) ; 3*randn(1,n); -randn(1,n) ];
Xfalse = randn(7,n);

X = [Xtrue;Xfalse];
Y = sign(sum(Xtrue, 1));
D = {1:3};

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%
end

