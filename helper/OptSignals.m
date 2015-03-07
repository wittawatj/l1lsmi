function OS = OptSignals()
%
% Define many optimization signals in one struct.
% This is intended to be used for comparison with the signal returned by an
% optimization algorithm.
%

% Initial call to the objFunc. 
OS.INIT_CALL = 1;

% Initial call to the objFunc in the line search procedure.
OS.INIT_LINE_SEARCH = 2;

% Call to the objFunc in the line search procedure (not the initial call )
OS.LINE_SEARCH = 3;

% Last call in the line search procedure (evaluate Hessian at the new
% point). This call is to give the gradient used for updating the
% parameter.
OS.LAST_LINE_SEARCH = 4;

% General call to the objFunc
OS.GENERAL_CALL = 5;

% Call with another variable which is not optimization variable
OS.NON_PARAM_CALL = 6;

end

