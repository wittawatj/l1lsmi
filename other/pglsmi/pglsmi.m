function [Wh,f, infoLog] = pglsmi( X, Y, options)
    if nargin < 3
        options =[];
    end
    if isclassification(X,Y)
        [Wh,f, infoLog] = pglsmi_dis( X, Y, options);
    else
        [Wh,f, infoLog] = pglsmi_cont( X, Y, options);
    end


end

