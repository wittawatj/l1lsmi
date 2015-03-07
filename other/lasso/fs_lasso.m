function S = fs_lasso(X, Y, options )
%
% Feature selection with Lasso algorithm.
% Find lambda such that k features can be obtained.
% LASSO cannot handle a multiclass problem.
% 

% Number of lambdas to try
numlambda = myProcessOptions(options, 'lasso_numlambda', 100);

Y = double(Y);
isclass = isclassification(X,Y);

k = options.k;

t0 = cputime;
tic;
UY = unique(Y);
        
if isclass 
    c = length(UY);
    if c > 2 % multiclass
        S = [];
        return;
    else % binary
        % Make sure that Y \in {-1,1}
        I = Y==UY(1);
        Y(I) = -1;
        Y(~I) = 1;
    end
end

[B, FitInfo] = lasso(X', Y', 'NumLambda', numlambda);
numF = sum(logical(B),1)';
[SR, SI]=sortrows([ abs(numF-k), numF-k, FitInfo.MSE', FitInfo.Lambda'] , 1:4);

Beta = B(:, SI(1))';
[SB, SBI] = sort(abs(Beta), 'descend');
nz = nnz(Beta);
F = false(1, size(X,1));
% In the case that the number of selected features > k, retain only k
% features having highest absolute coefficients.
F(SBI(1:min(nz, k))) = true;

timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.ranked = SBI;
S.weights = Beta;
S.B = B;
S.FitInfo = FitInfo;


if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

end

