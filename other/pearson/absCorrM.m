function Corr = absCorrM(X,Y)
% From www.cs.waikato.ac.nz/~mhall/icml2000.ps
% Weighted correlation for multiclass data
%
    uY = unique(Y);
    assert(length(uY) > 1);
    [m n] = size(X);
    
    YY = zeros(length(uY) , n);
    for yi = 1:length(uY)
        YY(yi,:) = (Y == uY(yi) ); % binary vector
    end
    
    Corr = zeros(m, 1 );
    for i = 1:m
        Xi = X(i,:);
        rhoi = 0;
        for j=1:length(uY)
            YYj = YY(j,:) ;
            rhoij = absCorrR(Xi, YYj );
            rhoi = rhoi + rhoij*( sum(YYj)/n );
            
        end
        
        Corr(i) = rhoi;
    end
   
end