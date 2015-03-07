function [ X, Y, D ] = meta_exp( n, seed, uniform, noise )
% 
% 
% 

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

% uniform
X1 = rand(uniform, n)*2 -1;

% Gaussian noises
X2 = randn(noise, n) ;

X = [X1;X2];

divi = uniform;
% non-linear dependency to Y (Immitate one of artificial datasets in HSIC paper)
Y = exp(-sum(X1.^2,1)/divi) + 0.1*randn(1, n);   
D = {1:uniform};


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

end
