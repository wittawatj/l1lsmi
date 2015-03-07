function [ X, Y, D] = gen_log3( n, seed )
% 
% 3 true features. Regression.
% With some redundant features.
% Total 10 features
% 

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

X1_3 = 2*(2*rand(3,n)-1);
X4_6 = 0.1*X1_3 + 1 + randn(3,n);
X7_10 = randn(4,n); 

X = [X1_3; X4_6; X7_10];
Y = log(1+sum(abs(X1_3),1));
D = {1:3};


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

