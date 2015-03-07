function Ky = kerDelta(Yc, Y)
% Calculate basis expansion using Delta kernel
% Assume both Samples and Centers are row vectors
%
    b = length(Yc);
    n = length(Y);
    U = unique(Yc);
    Ky = zeros(b,n);
    for y = U
        Ky( (y==Yc) , (y==Y) ) = 1;
    end
    
end
