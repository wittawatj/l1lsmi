function [ X, Y, D ] = gen_prodchain5(n, seed)
%
% Regression. 5 true features. 
% Y = (x1+x2)(x2+x3)(x3+x4)(x4+x5)
% With redundant features
%


% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

X1_5 = randn(5,n)+1;
X6_10 = 2*X1_5 + randn();
X12 = X1_5(1,:).*X1_5(2,:) + 2*randn();
X23 = X1_5(2,:).*X1_5(3,:) + 2*randn();
X34 = X1_5(3,:).*X1_5(4,:) + 2*randn();
X45 = X1_5(4,:).*X1_5(5,:) + 2*randn();
X51 = X1_5(5,:).*X1_5(1,:) + 2*randn();

XN = rand(5, n); % 5-dimension uniform noises
X = [X1_5;X6_10;X12;X23;X34;X45;X51;XN];

Y = (X1_5(1,:)+X1_5(2,:)).*(X1_5(2,:)+X1_5(3,:)).*(X1_5(3,:)+X1_5(4,:)).*...
    (X1_5(4,:)+X1_5(5,:)) + randn(1,n);
D = {1:5};


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
