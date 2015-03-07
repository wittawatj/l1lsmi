function [Wh,f] = wlsmi( X, Y, options)
    if nargin < 3
        options =[];
    end
    if isclassification(X,Y)
        SW = wlsmi_dis( X, Y, options);
    else
        SW = wlsmi_cont( X, Y, options);
    end
    Wh = SW.Wh;
    f = SW.nlsmi;


end

