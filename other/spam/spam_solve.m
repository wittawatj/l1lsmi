function [A, ctime, ttime] = spam_solve(KK, Y, lambda, rho)
%
% Solve SpAM's optimization problem as defined in the paper
% "Minimax-Optimal Rates for Sparse Additive Models" (jmlr).
% The optimization problem is defined in Eq. 7.
% CVX is used to solve the problem.
% 
% Follow the notation in the paper:
%  d = dimension, 
%  n = sample size
% 
% Input:
%  KK = nxnxd kernel matrices of each dimension
%  Y = an n-dimensional vector of output
%  lambda = sparseness regularization parameter
%  rho = smoothness parameter
%
% Output:
%  A = nxd matrix of coefficients
%  ctime = cputime spent solving
%  ttime = tic/toc time spent solving
% 
% ** How SpAM deals with multi-class problems ?
% 

cvx_solver sdpt3
% cvx_solver sedumi

d = size(KK,3);
n = length(Y);
Ym = mean(Y);
Y = Y(:);

% compute sqrtm of KKj. This is actually not needed. But, they are used
% just to follow CVX's DCP ruleset.
SQ = cell(d,1);
for j=1:d
  SQ{j} = real(sqrtm(KK(:,:,j)));  
end

% variables for time
ct = cputime;
tt = tic;

cvx_begin

    variable A(n,d);
    t1 = (0.5/n)*quad_over_lin(Y - Ym - KK(:,:)*A(:), 1); % term 1
    temp2 = 0;
    t3 = 0;
    for j=1:d
        KKj = KK(:,:,j);
        Aj = A(:,j);
        temp2 = temp2 + norm( KKj*Aj);        
%         t3 = t3 + rho*pow_p(Aj'*KKjAj, 0.5);

%         Not efficient to factor a matrix but I do not know what to
%         do. CVX accepts only DCP forms.
        t3 = t3 + rho*norm(SQ{j}*Aj);

        % constraint
        quad_form(Aj, KKj) <= 1;
    end
    t2 = (lambda/sqrt(n))*temp2;
    
    minimize( t1 + t2 + t3 );
    
cvx_end

ctime = cputime - ct;
ttime = toc(tt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
