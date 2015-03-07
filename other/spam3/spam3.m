function [A, ctime, ttime] = spam3(KK, Y, r)
%
% Solve SpAM's optimization problem as defined in the paper
% "High-Dimensional Feature Selection
% by Kernel-Based Feature-Wise Non-Linear Lasso"
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
cvx_solver sedumi

d = size(KK,3);
n = length(Y);
Ym = mean(Y);
Y = Y(:);

% variables for time
ct = cputime;
tt = tic;

cvx_begin

    variable A(n,d);
    t1 = quad_over_lin(Y - Ym - KK(:,:)*A(:), 1); % term 1
%     t1 = norm(Y - Ym - KK(:,:)*A(:), 2); % term 1
    temp2 = 0;
    for j=1:d
        KKj = KK(:,:,j);
        Aj = A(:,j);
        temp2 = temp2 + norm( KKj*Aj);        

    end
    t2 = temp2/sqrt(n);
    
    minimize( t1);
    subject to
        t2 <= r;
cvx_end

ctime = cputime - ct;
ttime = toc(tt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
