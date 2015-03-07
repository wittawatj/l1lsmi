function [ X, Y, D] = gen_fvm( n, seed )
% 
% Dataset from FVM paper.
% "From lasso regression to feature vector machine"
% 
% 100 features. Regression.
% 

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


f1 = rand(1,n);
f3 = rand(1,n);
f2 = 2*rand(1,n) - 1;

F4_33 = repmat(3*f1, 30, 1) + randn(30,n);
F34_72 = repmat(sin(10*f2), 39, 1) + randn(39, n);
F73_100 = rand(28, n);

X = [f1;f2;f3;F4_33;F34_72;F73_100];
Y = sin(10*f1 - 5) + 4*sqrt(1-f2.^2) - 3*f3 + randn(1,n);
D = {1:3};


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

