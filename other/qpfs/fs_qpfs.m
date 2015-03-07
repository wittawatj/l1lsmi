function S = fs_qpfs(X, Y, options )
%
% Perform feature selection with QPFS
% "Quadratic Programming Feature Selection" (QPFS) (in JMLR).
% Pearson correlation is used for feature similarity and dependency
% measure. Y can be a regression, binary or a multiclass output. X has to
% be only real or binary.
% 
% Use CVX to solve the quadratic programming problem.
%
[m n] = size(X);

k = options.k;

t0 = cputime;
tic;

if isclassification(X,Y) && length(unique(Y)) > 2 
    % Assume a classification task
    f = absCorrM(X, Y);
else % regression or binary classification
    f = absCorrR(X, Y);
end
assert(all(size(f)==[m 1]));
Q = abs(corr(X')); % require statistical toolbox of Matlab
% symmetrize Q
Q = (Q+Q')/2;

% truncate negatice eigenvalues to make Q positive semi-definite.
% This part is my own implementation (not in the paper).
[V D] = eig(Q);
Ev = diag(D);
if ~all(Ev > 0)
    I = Ev > 0;
    TV = V(:,I);
    Q = TV*diag(Ev(I))*TV';
    Q = (Q+Q')/2;
end
epsilon = 1e-7;
Q = Q + epsilon*eye(m);

% alpha parameter. 
% high alpha => focus more of relavancy, less focus on redundancy
% alpha is between 0 and 1.
qbar = mean(Q(:));
fbar = mean(f);
default_alpha = qbar/(qbar + fbar);% recommended in the paper
alpha = myProcessOptions(options, 'qpfs_alpha', default_alpha);

%%%% Solve with CVX

% cvx_solver sdpt3
% cvx_solver sedumi
cvx_begin

    variable W(m, 1);
   
    minimize( 0.5*(1-alpha)*W'*Q*W - alpha*f'*W );
    subject to
        W >= 0;
        sum(W) == 1;
cvx_end

F = false(1 , m );
[SW, SWI] = sort(W, 'descend');
F(SWI(1:k)) = true;

timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.W = W;
S.f = f;
S.alpha = alpha;
S.Q = Q;

if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
