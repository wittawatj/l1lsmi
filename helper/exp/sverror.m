function SV = sverror( FX, Y, o )
%
% Evaluate the dataset with cross validation of SVM/SVR.
%

if nargin < 3
    o = [];
end

% fold = myProcessOptions(o, 'fold', 5);
fold = 3; % fixed to 3

% learner's options
learneropts.fold = fold;
learneropts.libsvm_isclassi = isclassification(FX,Y);
learneropts.libsvm_C = 10.^(-3:2:4);
learneropts.libsvm_sigmaxfactor_list = [1/5, 1/2, 1, 2, 5];


[bestsigmafactor, bestc, libsvm_err, CVErr] = libsvm_cv( FX, Y, learneropts);
SV.bestsigmafactor = bestsigmafactor;
SV.bestc = bestc;
SV.libsvm_err = libsvm_err;
SV.CVErr = CVErr;

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

