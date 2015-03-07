function Corr = absCorrR(X,Y)
% Return a column vector
    Corr = abs(corr(X', Y'));
%     [m n] = size(X);
%     Corr = zeros(m, 1 );
%     for i = 1:m
%         Xi = X(i,:);
%         rhoi = corr(Xi', Y');
%         
%         Corr(i) = abs(rhoi);
%     end
end