function [bestsigmaxfactor, bestc, minerr, CVs, C, Gamma] = libsvm_cv( X, Y, options)
%
% Perform CV with libsvm
%

assert(size(X,2) == size(Y,2));
% Normalize data
X = normdata(X);

if nargin < 3
    options = [];
end

isclassi = myProcessOptions(options, 'libsvm_isclassi', isclassification(X, Y)); 
C = myProcessOptions(options, 'libsvm_C', 10.^(-2:3));
sigmaxfactor_list = myProcessOptions(options, 'libsvm_sigmaxfactor_list',...
    [1/5, 1/2, 1, 2, 5]);

med = meddistance(X);
Sigma = med*sigmaxfactor_list;
Gamma = 1./(2*Sigma.^2);
fold = myProcessOptions(options, 'fold', 2);

CVs = inf(length(C) , length(Gamma) );

for c_i = 1:length(C),
  c = C(c_i);
  for g_i = 1:length(Gamma),
    g = Gamma(g_i); %   exp(-gamma*|u-v|^2)

    types = [0 3]; % 0 = SVC, 3 = epsilon SVR
    svm_type = types( ~logical(isclassi) + 1 );
    cmd = sprintf('-v %d -c %g -g %g -s %d', fold, c, g, svm_type);
    
    cmd
    cv = svmtrain(Y', double(X'), cmd);
    if svm_type == 0 % SVC
       cv = 1-cv/100 ;
    elseif svm_type == 3 % SVR
       % take sqrt to make it a root mean squared error
       cv = sqrt(cv);
    end
    CVs(c_i, g_i) = cv ;
    
  end
end
[minerr, temp_i] = min(CVs(:));
[best_ci, best_si] = ind2sub(size(CVs), temp_i); 
bestc = C(best_ci);
bestsigmaxfactor = sigmaxfactor_list(best_si);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

