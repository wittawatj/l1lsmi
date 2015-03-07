function KG = knngauss_error( FX, Y, o )
%
% Evaluate the dataset with cross validation of Knn/Gaussian regression
%

if nargin < 3
    o.seed = 1;
end

fold = myProcessOptions(o, 'fold', 5);

% learner's options
learneropts.fold = fold;
learneropts.gaussreg_sigmafactor_list = [1/5, 1/2, 1, 2, 5];
learneropts.gaussreg_lambda_list = 10.^(-3:4);
learneropts.knn_K = [1 2 5 7 10 20 30];
learneropts.seed = o.seed;

if isclassification(FX,Y)
    [ bestk, knn_err, CVErr] = knn_cv( FX, Y, learneropts);
    KG.bestk = bestk;
    KG.learner_err = knn_err;
    KG.CVErr = CVErr;

else
    [bestsigmafactor, bestlambda, gaussreg_err, CVErr] = gaussRegression_cv( FX, Y, learneropts);
    KG.bestsigmafactor = bestsigmafactor;
    KG.bestlambda = bestlambda;
    KG.learner_err  = gaussreg_err;
    KG.CVErr = CVErr;

end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

    