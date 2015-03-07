function [ nhsic, DF] = funObjNegHSIC( W, X, LH, HLH, options, refInfo)
% 
% 
[m n] = size(X);

if all(W==0)
    nhsic = inf;
    DF = zeros(m,1);
    return;
end

Z = bsxfun(@times, W, X);
if useMedHeu(refInfo, options)
    % Median heuristic should be used in this iteration
    sigmaz = meddistance(Z);
    fprintf('medz: %.3g \n', sigmaz);
    refInfo.obj.sigmaz = sigmaz;
else
    % Median heuristic should not be used in this iteration
    sigmaz = refInfo.obj.sigmaz;
end

% K = kerGaussian(Z, Z, sigmaz);
K = kerSelfGaussian(Z, sigmaz);
KHT = bsxfun(@minus, K, mean(K, 1) );
hs = (KHT(:)' * LH(:) )/ ((n-1)^2);

nhsic = -hs;

% Derivative
if nargout > 1
    DF = zeros(m,1);
    M = HLH;
    for k=find( W(:)' > 1e-10) 
        Wk = W(k);
        
        % calculate Dk
        Xk = X(k,:)';
        Xk2 = Xk.^2;
        
%         MX = bsxfun(@times, Xk, M);
%         KX = bsxfun(@times, Xk', K);
%         r = sum(M.*K,1)*Xk2 - MX(:)'*KX(:);
        KXX = K.*(Xk*Xk');
        r = sum(M.*K,1)*Xk2 - M(:)'*KXX(:);
        
        DF(k) = -(2*Wk/(sigmaz*sigmaz*(n-1)^2)) * r;

    end
    DF = -DF;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use finite difference to check the calculation of DF
%     epsi = 1e-6;
%     eDF = zeros(m,1);
%     nhsicf = @(w)nhsicfunc(w, X, LH, HLH, options);
%     lw = nhsicf(W);
%     for k=1:m
%         E = zeros(m,1);
%         E(k) = epsi;
%         Wk = W + E;
%         hsic_k = nhsicf(Wk);
%         eDF(k) = (hsic_k - lw)/epsi;
%     end
%     display(sprintf('|eDF - DF| = %.3g',norm(eDF-DF)));    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function nhsic = nhsicfunc(W, X, LH, HLH, options)
    n = size(X,2);
    Z = bsxfun(@times, W, X);

    sigmaz = meddistance(Z);

    K = kerGaussian(Z, Z, sigmaz);
    KHT = bsxfun(@minus, K, mean(K, 1) );

    hs = (KHT(:)' * LH(:) )/ ((n-1)^2);
    nhsic = -hs;

end