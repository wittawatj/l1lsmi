function [ opt] = lbfgsOptions( )
% 
% Default options for fminlbfgs solver.
% 

% Options for optimizer
opt.optTol = 1e-5;
opt.TolFun = 1e-5;
opt.MaxIter = 50;
opt.GradObj = 'on';
opt.GradConstr = 'false';
opt.HessUpdate = 'lbfgs';
opt.Display = 'iter';


%%%%%%%%%%%%%%%%%%%%%%%%%%
end

