function [obj, dObj] = augmentPenalty(W, fun, v, wpenaltyfunc)
    if nargout > 1 
        [f dF] = fun(W);
        [p, dP] = wpenaltyfunc(W);        
        dObj = dF + v*dP;
    else
        f = fun(W);
        p = wpenaltyfunc(W);
    end
    obj = f + v*p;
end

