function DX = sigmadiscretize2( X, level )
%
% Discretize each variable in X. 
% Similar to sigmadiscretize, sigmadiscretize2 put values into bins defined
% by (i*sigma) + [\mu - 0.5\sigma, \mu + 0.5\sigma]. 
% 
% X is mxn where m is the number of variables, and n is the number of
% samples. There are totally 2*(level)+1 possible values.
%

if level<=0
    error('level must be positive.');
end

M = mean(X,2);
XM = bsxfun(@minus, X, M);
SD = std(X, 0, 2);

Splits = SD*( ((-(level-1)):level) - 0.5);
DX = ones(size(X));
for i=1:size(Splits,2)
    Ind = bsxfun(@(a,b)(a>b), XM, Splits(:,i));
    DX(Ind) = i+1;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

