function [B, ctime, ttime] = spam2(KK, Y, lambda, options)
%
% Solve SpAM's optimization problem as defined in the paper
% "High-Dimensional Feature Selection by Kernel-Based Feature-Wise Non-Linear Lasso".
% There is no constraint in this formulation. We use gradient descent here.
% 
% Follow the notation in the paper:
%  d = dimension, 
%  n = sample size
% 
% Input:
%  KK = nxnxd kernel matrices of each dimension
%  Y = an n-dimensional vector of output
%  lambda = sparseness regularization parameter
%
% Output:
%  B = nxd matrix of coefficients
%  ctime = cputime spent solving
%  ttime = tic/toc time spent solving
% 
% ** How SpAM deals with multi-class problems ?
% *** L2 is not continuously differentiable ***
% 
error('l2 is not differentiable. Use spam3 instead.');

if nargin < 4
    options = [];
end
d = size(KK,3);
n = length(Y);
Y = Y(:);

% variables for time
ct = cputime;
tt = tic;

% Optimization starts
KT1 = squeeze(sum(KK,1)); % nxd
KY = reshape(Y'*KK(:,:), n , d);

fobj = @(Bvec)(spam_obj_vec(Bvec, KT1, KY, KK, Y, lambda));
B0 = rand(n ,d)*5;
[Bvec,f,exitflag,output] = minFunc(fobj, B0(:) ,options);

ctime = cputime - ct;
ttime = toc(tt);

B = reshape(Bvec, n, d);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function [f Gvec] = spam_obj_vec(Bvec, KT1, KY, KK, Y, lambda)
    n = size(KK,1);
    d = size(KK,3);
    B = reshape(Bvec, n, d);
    if nargout > 1
        [f G] = spam_obj(B, KT1, KY, KK, Y, lambda);
        Gvec = G(:);
    else
        f = spam_obj(B, KT1, KY, KK, Y, lambda);
    end
    
end

function [f G] = spam_obj(B, KT1, KY, KK, Y, lambda)
    n = size(KK,1);
    d = size(KK,3);
    KB = zeros(n ,d);
    for i=1:d
        KB(:,i) = KK(:,:,i)*B(:,i);
    end
    KBnorm = sqrt(sum(KB.^2, 1)); %1xd
    S = sum(KB,2);
    Diff = Y - S;
    f = Diff'*Diff + (lambda/sqrt(n))*sum(KBnorm);
    if nargout > 1
        
        G  = -2*KY + reshape(S'*KK(:,:), n, d); %loss derivative
        
        % penalty derivative
        G = G + (lambda/sqrt(n))* bsxfun(@rdivide, KT1, KBnorm);
    end
end



