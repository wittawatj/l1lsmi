function [Wh,f, infoLog] = dhsic( X, Y, options)
    if nargin < 3
        options =[];
    end
    if isclassification(X,Y)
        [Wh,f, infoLog] = dhsic_dis( X, Y, options);
    else
        [Wh,f, infoLog] = dhsic_cont( X, Y, options);
    end


end

