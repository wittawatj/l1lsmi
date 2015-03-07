function [ bestsigmafactor, bestlambda, minerr, CVErr ] = gaussRegression_cv( X, Y, options)
%
% KNN cross validation
%
if nargin < 3
    options = [];
end

[m n] = size(X);

sigmafactor_list = myProcessOptions(options, 'gaussreg_sigmafactor_list', ...
    [1/5, 1/2, 1, 2, 5] );
sigma_list = meddistance(X)*sigmafactor_list;
lambda_list = myProcessOptions(options, 'gaussreg_lambda_list', 10.^(-3:2:3));
fold = myProcessOptions(options, 'fold', 2);
seed = myProcessOptions(options, 'seed', 1);

I = strapartregression( n, fold, seed);
CVErr = inf(length(sigmafactor_list), length(lambda_list));

for si=1:length(sigma_list)
    sigma = sigma_list(si);
    for li=1:length(lambda_list)
        lambda = lambda_list(li);
        
        Err = zeros(fold, 1);
        for fi=1:fold
            Ite = I(fi,:);
            Itr = ~Ite;

            Xtr = X(:,Itr);
            Xte = X(:,Ite);
            Ytr = Y(Itr);
            Yte = Y(Ite);

            f = gaussRegression(Xtr, Ytr, sigma, lambda);
            eY = f(Xte);
            
            % root mean squared error
            Err(fi) = sqrt(mean((Yte - eY).^2));
        end
        err = mean(Err);
        CVErr(si, li) = err;
    end    
end
[minerr , temp_i] = min(CVErr(:));
[best_si, best_li] = ind2sub(size(CVErr), temp_i);
bestsigmafactor = sigmafactor_list(best_si);
bestlambda = lambda_list(best_li);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

