function [ Wh, Info ] = nemisolver(W0, fobj, options, infoRef)
% 
% General (un)constrained first-order solver with Nemirovski's line search.
% FRom paper "Large-scale Sparse Logistic Regression"
%
% W0 = m-dimensional vector for initial point
% fobj = function which returns objective value and gradient. The function
% should take at least two arguments: W, and a struct containing information 
% provided by the solver.
% - L0 may be set to 1/n where n is the number of samples.
% 

% Progress threshold = threshold on the difference of the objective values 
% of last two iterations
progTol = myProcessOptions(options, 'progTol', 1e-5);

% maximum number of nonzero features before stopping the iterations
% This is useful when constraint space is an l1 ball.
nzthreshold = myProcessOptions(options, 'nzthreshold', 1);

% Terminate if the distance from current parameter to the parameter in the
% previous iteration is less than this threshold. 
distTol = myProcessOptions(options, 'distTol', 1e-3);

% Beta is a vector of beta's
Beta = [];

% Record of objective function values
F = [inf];

% Initial L0
L0 = options.initL;
L = [];
T = [];
% maximum number of iterations allowed. 
maxIter = myProcessOptions(options, 'maxIter', 200);

% constraint projection operator. This is a function which takes W and
% return W projected onto the constraint space. Identity function makes it
% unconstrained.
conprojFunc = myProcessOptions(options, 'conprojFunc', @(w)(w));

W0 = conprojFunc(W0);

Ws = [W0];

% Begin
t_pp = 0;% pp means previous-previous
t_p = 1;        
L_p = L0;% previous L
W_k = W0;
W_p = W0;
stop = false;

OS = OptSignals();
for k=1:(maxIter-1)
    % Update iteration number in infoRef
    infoRef.obj.iteration = k;
    infoRef.obj.signal = OS.NON_PARAM_CALL;
    
    b_k = (t_pp-1)/t_p; % beta_k
    L_k = L_p;
    S_k = W_k + b_k*(W_k - W_p);
    [fs, Gs] = fobj(S_k, infoRef);
    gs2norm = Gs'*Gs;
    
    infoRef.obj.signal = OS.INIT_LINE_SEARCH;
    while true
        W_n = conprojFunc(S_k - Gs/L_k);
        fw_n = fobj(W_n, infoRef);
        if fw_n <= fs - gs2norm/(2*L_k) 
            break;
        else
            L_k = 2*L_k;
        end
        
        if norm(W_n - S_k) <= 1e-8 || L_k >= 1e7
            stop = true;
            break;
        end
        % LINE_SEARCH signal
        infoRef.obj.signal = OS.LINE_SEARCH;
        
    end
    t_k = (1+sqrt(1+4*t_p^2))/2;
    display(sprintf('#It: %d, f: %.3e', k, fw_n));
    % Update
    Beta(k) = b_k;
    L(k) = L_k;
    T(k) = t_k;
    Ws(:,k+1) = W_n;
    F(k+1) = fw_n;
    
    % check for convergence
    if stop ...
            || nnz(W_n) <= nzthreshold ...
            || norm(W_n - W_k) <= distTol
        break;
    end
    if k>=2 && mean(abs(diff(F((k-1):(k+1))))) <= progTol
        break;
    end
    
    t_pp = t_p;
    t_p = t_k;
    L_p = L_k;
    W_p = W_k;
    W_k = W_n;
    
end

Info.F = F;
Info.Ws = Ws;
Info.L = L;
Info.T = T;
Info.Beta = Beta;

Info.options = options;

Wh = W_n;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

