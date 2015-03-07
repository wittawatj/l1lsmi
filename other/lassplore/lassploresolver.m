function [ Wh, Info ] = lassploresolver(W0, fobj, options)
%
% A general constrainted optimization solver based on LASSPLORE.
% "Large-scale sparse logistic regression". The solver should be able to
% solve any problems as long as the constraint can be formulated as a
% projection operation on the respective constraint space.
%
% W0 = m-dimensional vector for initial point
% fobj = function which returns objective value and gradient. The function
% should take at least two arguments: W, and a struct containing information 
% provided by the solver.
% - L0 may be set to 1/n where n is the number of samples.
%

% Optimality threshold = threshold on 2norm of the gradient 
optTol = myProcessOptions(options, 'optTol', 1e-6);

% Progress threshold = threshold on the difference of the objective values 
% of last two iterations
progTol = myProcessOptions(options, 'progTol', 1e-5);

% maximum number of nonzero features before stopping the iterations
% This is useful when constraint space is an l1 ball.
nzthreshold = myProcessOptions(options, 'nzthreshold', 1);

% Regularization parameter for l2 norm on W. ... rho/2*||W||^2 in the
% objective function.
rho = myProcessOptions(options, 'rho', 0);

% \tilde{\mu} in the paper. Assumption in the paper is that mu >= rho >= 0.
mu = rho;
assert(mu >= 0);

% alpha_{-1} in the paper.
% Alpha is a vector of alpha's.
Alpha = [0.5]; 

% Beta is a vector of beta's
Beta = [nan];

% Record of objective function values
F = [inf, inf];

% Initial L0
L2 = options.initL;
L = [L2 L2];

if mu > 0
    gamma0 = mu;
else
    % mu = 0
    gamma0 = 1;
end

Gamma = [gamma0 gamma0];

% maximum number of iterations allowed. 
maxIter = myProcessOptions(options, 'maxIter', 200);

% constraint projection operator. This is a function which takes W and
% return W projected onto the constraint space. Identity function makes it
% unconstrained.
conprojFunc = myProcessOptions(options, 'conprojFunc', @(w)(w));

W0 = conprojFunc(W0);

Ws = [W0 W0];

for k=2:(maxIter+1)
    L_k = L(k);
    W_k = Ws(:,k);
    [fw, Gw] = fobj(W_k, []);
    display(sprintf('#It: %d, f: %.3e', k, fw));
    prevW = Ws(:,k-1);
    while true 
        gamma_k = Gamma(k);
        mmg = mu - gamma_k;
        
        alpha_k = (mmg + sqrt(mmg^2 + 4*L_k*gamma_k))/(2*L_k);
        Gamma(k+1) = (1-alpha_k)*gamma_k + alpha_k*mu;
        beta_k = gamma_k*(1-Alpha(k-1))/(Alpha(k-1)*(gamma_k + L_k*alpha_k));
        Beta(k) = beta_k;
        S_k = W_k + beta_k*(W_k - prevW);

        nextW = conprojFunc(S_k - (1/L_k)*Gw);
        [fs, Gs] = fobj(S_k, []);
        NMS = nextW - S_k;
        nms2 = 0.5*L_k*(NMS'*NMS);
        [fnextw, Gnextw] = fobj(nextW);
        gsnms = Gs'*NMS;
        if  fnextw <= fs + gsnms + nms2
            break;
        else
            L_k = 2*L_k;
        end
    end
    Alpha(k) = alpha_k;
    F(k+1) = fnextw;
    L(k) = L_k;
    Ws(:,k+1) = nextW;
    tau = nms2/(fnextw - fs - gsnms);
    L(k+1) = hFunc(tau)*L_k;
    
    % check for convergence
    if nnz(nextW) <= nzthreshold ...
            || abs(F(k)-F(k+1)) <= progTol ...
            || norm(Gnextw) <= optTol
        break;
    end
end

Info.F = F;
Info.Ws = Ws;
Info.L = L;
Info.Alpha = Alpha;
Info.Beta = Beta;
Info.Gamma = Gamma;
Info.options = options;

Wh = nextW;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


function h = hFunc(tau)
    if tau >= 1 && tau <= 5
        h = 1;
    elseif tau > 5
        h = 0.8;
    else
%         error('tau is %.f which is out of range', tau);
        display(sprintf('tau is %.f which is out of range', tau))
        h = 0.8;
    end
end