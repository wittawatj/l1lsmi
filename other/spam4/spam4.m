function [A, ctime, ttime] = spam4(KK, Y, r)
%
% Solve SpAM's optimization problem as defined in the paper
% "High-Dimensional Feature Selection
% by Kernel-Based Feature-Wise Non-Linear Lasso"
% Use variable substitution s_k =  K_k Beta_k.
% Then restore Beta_k by Beta_k = K_k^-1 s_k
% 
% CVX is used to solve the problem.
% 
% Follow the notation in the paper:
%  d = dimension, 
%  n = sample size
% 
% Input:
%  KK = nxnxd kernel matrices of each dimension
%  Y = an n-dimensional vector of output
%  r = sparseness regularization parameter (ball's radius)
%
% Output:
%  A = nxd matrix of coefficients
%  ctime = cputime spent solving
%  ttime = tic/toc time spent solving
% 
% ** How SpAM deals with multi-class problems ?
% 

% cvx_solver sdpt3
% cvx_solver sedumi

d = size(KK,3);
n = length(Y);
Ym = mean(Y);
Y = Y(:);

% variables for time
ct = cputime;
tt = tic;

cvx_begin

    variable S(n,d);
    t1 = quad_over_lin(Y - Ym - sum(S,2), 1); % term 1

    temp2 = 0;
    for j=1:d
        temp2 = temp2 + norm( S(:,j));        
    end
    t2 = temp2/sqrt(n);
    
    minimize( t1);
    subject to
        t2 <= r;
cvx_end

A = zeros(n,d);
epsilon = 1e-6;
for j=1:d
    A(:,j) = (KK(:,:,j)+epsilon*eye(n))\S(:,j);
end
ctime = cputime - ct;
ttime = toc(tt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
