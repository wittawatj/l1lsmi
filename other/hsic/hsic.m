function hs = hsic( X, Y, options)
    if nargin < 3
        options =[];
    end
    if isclassification(X,Y)
        [ hs] = hsic_dis( X, Y, options);
    else
        [ hs] = hsic_cont( X, Y, options);
    end


end

