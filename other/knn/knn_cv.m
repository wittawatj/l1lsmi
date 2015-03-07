function [ bestk, minerr, CVErr ] = knn_cv( X, Y, options)
%
% KNN cross validation
%
if nargin < 3
    options = [];
end

K = options.knn_K; % knn_K
fold = myProcessOptions(options, 'fold', 2);
seed = myProcessOptions(options, 'seed', 1);

I = strapart(Y, fold, seed);    

CVErr = inf(length(K),1);
for ki=1:length(K)
    k = K(ki);
    Err = zeros(fold, 1);
    for fi=1:fold
        Ite = I(fi,:);
        Itr = ~Ite;

        Xtr = X(:,Itr);
        Xte = X(:,Ite);
        Ytr = Y(Itr);
        Yte = Y(Ite);

        eY = knn(Xtr, Ytr, Xte, k);
        Err(fi) = mean(eY ~= Yte);
    end
    err = mean(Err);
    CVErr(ki) = err;
end
[minerr , bestk_i] = min(CVErr);
bestk = K(bestk_i);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

