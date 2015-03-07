function [r, Rho]=redundancy_rate( X, use_abs )
%
% Calculate the redundancy rate of the features in X as described in 
% "Efficient spectral feature selection with minimum redundancy"
% Do we need to take an absolute of the correlation ?
%

if nargin <2
    use_abs = false;
end

m = size(X,1);
if m <= 1
    r = 0;
    return
end

% correlation matrix
R = corrcoef(X');
Rho = R;

if use_abs
    R= abs(R);
end

% Take the lower diagonal parts
corrs = R(logical(tril(ones(m),-1)));
r = sum(corrs)/(m*(m-1));


end

