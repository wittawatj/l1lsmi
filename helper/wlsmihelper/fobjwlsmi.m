function [ nlsmi, DF] = fobjwlsmi( W, X, Y, calc, options  )
% 
% Function object for WLMSI. Negative LSMI.
% 

[m n] = size(X);

if sum(abs(W)) == 0
    nlsmi = inf;
    DF = zeros(m,1);
    return;
end
    
% Initialize constants
Xc = calc.Xc;
Ky = calc.Ky;
lsmilambda = calc.lsmilambda;
b = size(Xc,2);

% Calculate negative LSMI
Z = bsxfun(@times, W, X);    
Zc = bsxfun(@times, W, Xc);    
KzPre = kerPreGaussian(Zc, Z);
Kz = exp(KzPre);

KyKz = Ky.*Kz;
h = mean(KyKz, 2);
KyKy = Ky*Ky';
KzKz = Kz*Kz';
H = (KyKy .* KzKz) ./ (n^2);
Alpha = (H + eye(b)*lsmilambda) \ h;
lsmi = 0.5*h'*Alpha - 0.5;
nlsmi = -lsmi;

% Ind = repmat(1:n, b, 1);
if nargout > 1
    
    
    %%%%%%%%%%%% V1 %%%%%%%%%%%%%%%%%%%%
    % Calculate the derivative
    sKyKz = sum(KyKz,2);
    DF = zeros(m,1);
    for k=find( W(:)' > 1e-10) 
        % If wk <= 1e-10, treat it as 0, and its derivative is also 0.
        wk = W(k);
          
        % Dh/dwk
        Xk = X(k,:)';
        Xk2 = Xk.^2;
        Xck = Xc(k,:)';
        Xck2 = Xck.^2;

        Dh = -(2*wk/n)*(KyKz*Xk2 - 2*Xck.*(KyKz*Xk) + Xck2.*sKyKz );

        % DH/dwk
        OXck = outeropt(Xck, Xck, @plus);
        OXck2 = outeropt(Xck2, Xck2, @plus);
        KzDk = bsxfun(@times, Xk', Kz);

        DH = -(2*wk/(n*n))*KyKy.*...
            (2*(KzDk*KzDk') - 2*(OXck.*(KzDk*Kz')) + OXck2.*KzKz);

        dIBywk = Alpha'*Dh - 0.5*Alpha'*DH*Alpha;
        DF(k) = dIBywk;
        
    end
    DF = -DF;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use finite difference to check the calculation of DF
%     epsi = 1e-6;
%     eDF = zeros(m,1);
%     lsmif = @(w)lsmifunc(w,X,Xc, Ky, best_sigmaz, best_lsmilambda);
%     lw = lsmif(W);
%     for k=1:m
%         E = zeros(m,1);
%         E(k) = epsi;
%         Wk = W + E;
%         lsmi_k = lsmif(Wk);
%         eDF(k) = (lsmi_k - lw)/epsi;
%     end
%     display(sprintf('|eDF - DF| = %.3g',norm(eDF-DF)));    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
end

