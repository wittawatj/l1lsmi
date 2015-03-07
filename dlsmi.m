function [Wh,f, infoLog] = dlsmi( X, Y, options)
    if nargin < 3
        options =[];
    end
    if isclassification(X,Y)
        [Wh,f, infoLog] = dlsmi_dis( X, Y, options);
    else
        [Wh,f, infoLog] = dlsmi_cont( X, Y, options);
    end


end

