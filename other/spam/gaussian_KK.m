function [ KK ] = gaussian_KK( X, sigma )
%
% Construct a nxnxd Gram matrices to be used with spam_solve.
% X is dxn.
%
[d n] = size(X);
KK = zeros(n,n,d);
for j=1:d
    Xj = X(j,:);
    Sj = Xj.^2;
    Kj = bsxfun(@plus, Sj', Sj) - 2*(Xj'*Xj);
    Kj = exp(-Kj./(2*sigma^2));
    KK(:,:,j) = Kj;
end


end

