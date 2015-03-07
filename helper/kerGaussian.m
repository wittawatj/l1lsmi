function K = kerGaussian(X1, X2, sigma)
%
% Gaussian kernel. 
% X1 = m x n1 matrix 
% X2 = m x n2 matrix
% Return K which is a n1 x n2 matrix.
%
% - d is the dimension. 
% - Each instance is a column vector. 
% - X1 and X2 can be just column vectors. 
%

% n1 = size(X1,2);
% n2 = size(X2,2);

if false && exist('pdist2', 'file') % pdist2 is somehow slow on large dataset
    K = exp(-(pdist2(X1', X2').^2)/(2*sigma^2) );
else
    
    D2 = bsxfun(@plus, sum(X1'.^2,2), sum(X2.^2,1)) - 2*(X1'*X2);
    
%     D2 = repmat(sum(X1'.^2,2), 1, n2) ...
%     + repmat(sum(X2.^2,1), n1, 1) ...
%     - 2*X1'*X2;

    K = exp(-D2./(2*sigma^2));
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end