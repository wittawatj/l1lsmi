function [Wh,f, infoLog] = pghsic( X, Y, options)
    if nargin < 3
        options =[];
    end
    if isclassification(X,Y)
        [Wh,f, infoLog] = pghsic_dis( X, Y, options);
    else
        [Wh,f, infoLog] = pghsic_cont( X, Y, options);
    end


end

