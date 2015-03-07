function [ X, Y, D] = gen_sin5( n, seed )
% 
% 5 true features. Regression.
% With some redundant features.
% Total 20 features
% 

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

X1_5 = 2*(2*rand(5,n)-1);
X6_10 = 2*X1_5 + 1 + randn(5,n);
X11_20 = randn(10,n); 

X = [X1_5;X6_10; X11_20];
Y = sin(sum(X1_5,1)) + 0.02*randn(1,n);
D = {1:5};


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

