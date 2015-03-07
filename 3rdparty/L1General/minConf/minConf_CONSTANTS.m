% Define constants used in minConf package.
% Mainly used to define the context in which funObj is called,
% and feedback signals to stop the optimization.
%
% Wittawat Jitkrittum
% May 24, 2011
%

SIGNAL_LINESEARCH = 1; % calling of funObj for the line search
SIGNAL_INIT = 2; % initial call of the funObj

% calling of funObj before doing the actual line search
% This call is actually to determine the reference point from which line search
% is performed.
SIGNAL_PRE_LINESEARCH = 3; 


FEEDBACK_STOP_OPT = 4; % signal to stop the optimization 
FEEDBACK_CONT_OPT = 5; % signal to continue the optimization 



