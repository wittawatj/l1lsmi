function DX = sigmadiscretize( X, level )
%
% Discretize each variable in X. 
% The value is discretized by putting into the appropriate bins defined by
% \mu +- level*\sigma. 
% 
% X is mxn where m is the number of variables, and n is the number of
% samples. There are totally 2*(level+1) possible values.
%
error('Check correctness first');

if level<0
    error('level must be non-negative.');
end

M = mean(X,2);
XM = bsxfun(@minus, X, M);
if level == 0
    % binary state
    DX = bsxfun(@(a,b)(a<=b), XM, 0 );
else
    % multi-state
    SD = std(X, 0, 2);
    Splits = SD*((-level):level);
    DX = ones(size(X));
    for i=1:size(Splits,2)
        Ind = bsxfun(@(a,b)(a>b), XM, Splits(:,i));
        DX(Ind) = i+1;
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

