function DF = deriveIByW(W, X, Xc, Alpha, Ky, Kz, sigmaz )
% 
% Derivative of SMI (0.5h'\alpha - 0.5) with respect to diagonal W.
% Return an m-dimensional column vector DF
% 
% Vectorization over m (dimensions) will not be done since m is assumed to
% be huge. 
% 

    DF = ver1(W, X, Xc, Alpha, Ky, Kz, sigmaz );
%     DF = ver2(W, X, Xc, Alpha, Ky, Kz, sigmaz );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function DF = ver1(W, X, Xc, Alpha, Ky, Kz, sigmaz )
    [m n] = size(X);

    KyKz = Ky.*Kz;
    sKyKz = sum(KyKz,2);
    KzKz = Kz*Kz';
    KyKy = Ky*Ky';

    DF = zeros(m,1);
    for k=find( abs(W(:)') > 1e-10) 
        % If wk <= 1e-10, treat it as 0, and its derivative is also 0.
        wk = W(k);
        % Can we take shunk of dimensions at a time (more than 1) ? Yes. Later.
        % Dh/dwk
        Xk = X(k,:)';
        Xk2 = Xk.^2;
        Xck = Xc(k,:)';
        Xck2 = Xck.^2;
        Dh = -(wk/(n*sigmaz*sigmaz))*(KyKz*Xk2 - 2*Xck.*(KyKz*Xk) + Xck2.*sKyKz );

        % DH/dwk
    %     Dk = sparse(1:n, 1:n, Xk, n, n);
        OXck = outeropt(Xck, Xck, @plus);
        OXck2 = outeropt(Xck2, Xck2, @plus);
        KzDk = bsxfun(@times, Xk', Kz);

        DH = -(wk/(n*n*sigmaz*sigmaz))*KyKy.*...
            (2*(KzDk*KzDk') - 2*(OXck.*(KzDk*Kz')) + OXck2.*KzKz);

        dIBywk = Alpha'*Dh - 0.5*Alpha'*DH*Alpha;
        DF(k) = dIBywk;

    end

end


function DF = ver2(W, X, Xc, Alpha, Ky, Kz, sigmaz )
    [m n] = size(X);
    KyKy = Ky*Ky';
    KyKz = Ky.*Kz;
    sKyKz = sum(KyKz,2);
    [b n] = size(Kz);
    
    DF = zeros(m,1);
    KzT = Kz';
    
    for k=find( abs(W(:)') > 1e-10) 
        % If wk <= 1e-10, treat it as 0, and its derivative is also 0.
        wk = W(k);
        % Can we take shunk of dimensions at a time (more than 1) ? Yes. Later.
        % Dh/dwk
        Xk = X(k,:)';
        Xk2 = Xk.^2;
        Xck = Xc(k,:)';
        Xck2 = Xck.^2;
        Dh = -(wk/(n*sigmaz*sigmaz))*(KyKz*Xk2 - 2*Xck.*(KyKz*Xk) + Xck2.*sKyKz );

        XMXc2 = bsxfun(@minus, Xc(k,:)', X(k,:)).^2;
        XMXc2T = XMXc2';
        DH = zeros(b,b);
        for l1=1:b
            Kz_l1 = KzT(:,l1);
            XMXc2_l1 = XMXc2T(:, l1);
            for l2=1:l1
                Kz_l2 = KzT(:, l2);
                XMXc2_l2 = XMXc2T(:, l2);
                DH(l1,l2) = (XMXc2_l1+XMXc2_l2)'*(Kz_l1.*Kz_l2);
            end
        end
        DH = DH + DH' - sparse(1:b, 1:b, diag(DH), b, b);
        DH = -(wk/(n*n*sigmaz*sigmaz))*KyKy.*DH;
        
        dIBywk = Alpha'*Dh - 0.5*Alpha'*DH*Alpha;
        DF(k) = dIBywk;

    end
end
