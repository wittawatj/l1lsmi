function [X, OBJ, INFO, LAMBDA] = qpoctave (X0, H, Q, A, B, LB, UB, A_LB, A_IN, A_UB)
% @author Wittawat Jitkrittum (11 June 2010)
% Call octave and use octave's qp function.
% The arguments are exactly the same as defined in octave.
% 
% [X, OBJ, INFO, LAMBDA] = qp (X0, H, Q, A, B, LB, UB,
%          A_LB, A_IN, A_UB)
%
%Solve the quadratic program
%
%               min 0.5 x'*H*x + x'*q
%                x
%
%     subject to
%
%               A*x = b
%               lb <= x <= ub
%               A_lb <= A_in*x <= A_ub
%
%     using a null-space active-set method.
if nargin < 10
	display('At least 10 arguments are required in order to call qp(). Try "help qp".')
	return;
end

%salt = sprintf('%f_%f', rand(1,1), now);
fname = [tempname '.mat'];
rfname = [tempname '.mat'];
%display(fname)
save(fname, 'X0', 'H', 'Q', 'A', 'B', 'LB', 'UB', 'A_LB', 'A_IN', 'A_UB' );
cmd = sprintf('LD_LIBRARY_PATH="" ;  octave  -q --eval "load(''%s''); [X, OBJ, INFO, LAMBDA] = qp(X0, H, Q, A, B, LB, UB, A_LB, A_IN, A_UB); save(''-V7'', ''%s'', ''X'', ''OBJ'', ''INFO'', ''LAMBDA''); " ', fname, rfname);
%display(cmd);
system(cmd);
load(rfname);


