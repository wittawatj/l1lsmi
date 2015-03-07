function [ X, Y, D] = gen_redun1( n, seed )
%
% Dataset with redundant features.
%

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

XT = randn(3, n);
X4 = XT(1,:)+XT(2,:) + 0.7*randn(1,n);
X5 = XT(1,:)+XT(3,:) + 0.7*randn(1,n);
X6 = XT(2,:)+XT(3,:) + 0.7*randn(1,n);
XF = randn(4,n);

X = [XT;X4;X5;X6;XF];
Y = sum(XT,1);

D = {1:3};


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

