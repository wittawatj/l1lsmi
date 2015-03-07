function [err, A, L] = libsvmtest( Xtr, Ytr,Xte, Yte, c, gamma )
%
% Train an SVM and test the model with the supplied test set.
% Each row in Xtr and Xte corresponds to one instance. 
%
error('Copied from my old works. Have to verify the correctness of the code!');

assert(size(Xtr,1) == size(Ytr,1));
assert(size(Xte,1) == size(Yte,1));

if nargin <4
    error('svmtest needs at least 4 arguments');
end


% detect the task (classification or regression)
l = length(unique(Ytr));
isclassification = (l <= 26);

if nargin < 5
	c = 100;
end

if nargin < 6
    % Use median distance by default
    
    % gamma in usual Gaussian kernel-> exp( -(|u-v|^2 )/(2*gamma^2) )
    med = meddistance(Xtr); 
	gamma = 1/(2*med^2); % gamma in libsvm -> exp(-gamma*|u-v|^2)

end

% Normalize data
Mxtr = mean(Xtr , 1);
SDxtr = diag(1./std(Xtr , 0 , 1));
Xtr= (Xtr - repmat(Mxtr , size(Xtr,1) , 1) ) * SDxtr;

% Use mean and SD from training data to normalize test data
Xte = (Xte - repmat(Mxtr, size(Xte,1), 1)) * SDxtr;

types = [3 0];
svm_type = types(isclassification + 1); % 0 = SVC, 3 = epsilon SVR
% We fix epsilon in eplison-SVR to default value (-p)
cmd = sprintf('-c %g -g %g -s %d', c, gamma, svm_type);
cmd

% train
model = svmtrain(double(Ytr), double(Xtr), cmd);

%  test
[L, A] = svmpredict(double(Yte), double(Xte), model);

if isclassification
    % err = classification error proportion for classification tasks
    err = 1 -A(1)/100;
else
    % err =  mean squared error for regression tasks
    err = A(2); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end