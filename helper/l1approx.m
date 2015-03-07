function [l1, dl1]= l1approx(W, epsi)
%
% Approximate an l1 norm
% W must be a column vector.
%

L1vec = sqrt(epsi + W.^2 );
l1 = sum(L1vec);

% derivative
if nargout > 1 
    dl1 = W./L1vec;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end