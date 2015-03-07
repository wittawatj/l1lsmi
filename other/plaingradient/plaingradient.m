function [ Wh, Info ] = plaingradient(W0, fobj, options, infoRef)
%
% Gradient descent algorithm without line search.
%


% Progress threshold = threshold on the difference of the objective values 
% of last two iterations
progTol = myProcessOptions(options, 'progTol', 1e-5);

% Optimality threshold = threshold on 2norm of the gradient 
optTol = myProcessOptions(options, 'optTol', 1e-5);

% maximum number of nonzero features before stopping the iterations
% This is useful when constraint space is an l1 ball.
nzthreshold = myProcessOptions(options, 'nzthreshold', 1);


% maximum number of iterations allowed. 
maxIter = myProcessOptions(options, 'maxIter', 200);

% constraint projection operator. This is a function which takes W and
% return W projected onto the constraint space. Identity function makes it
% unconstrained.
conprojFunc = myProcessOptions(options, 'conprojFunc', @(w)(w));

% Step size function
stepsizeFunc = myProcessOptions(options, 'stepsizeFunc', @(info)(1/sqrt(info.k)));

W0 = conprojFunc(W0);
Ws = [];

% Record of objective function values
F = [];

% Record of step size
T = [];

% Record of gradients
G = [];

OS = OptSignals();

% Update iteration number in infoRef
infoRef.obj.iteration = 1;
infoRef.obj.signal = OS.GENERAL_CALL;
W_k = W0;
[fw, Gw] = fobj(W_k, infoRef);
W_p = W_k;
Gw_p = Gw; 
for k=1:maxIter
    
    stepFuncInfo = struct('k', k, 'W_k', W_k, 'Gw', Gw, 'W_p', W_p , 'Gw_p', Gw_p);
    t = stepsizeFunc(stepFuncInfo);
    W_n = conprojFunc( W_k - t*Gw );
    
    % Update iteration number in infoRef
    infoRef.obj.iteration = k+1;
    infoRef.obj.signal = OS.GENERAL_CALL;
    [fw_n, Gw_n] = fobj(W_n, infoRef);
    
    F(k) = fw;
    Ws(:,k) = W_k;
    G(:,k) = Gw;
    T(k) = t;
    
    display(sprintf('#It: %d, f: %.3e', k, fw));
    
    % check for convergence
    if nnz(W_n) <= nzthreshold ...
            || norm(Gw_n) <= optTol 
        break;
    end
    if k>=3 && mean(abs(diff(F((k-2):k)))) <= progTol
        break;
    end
    W_p = W_k;
    Gw_p = Gw;
    
    W_k = W_n;
    Gw = Gw_n;
    
    fw = fw_n;
end

Info.F = F;
Info.Ws = Ws;
Info.G = G;
Info.T = T;
Info.options = options;

Wh = W_n;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

