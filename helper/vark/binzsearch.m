function [Z, FMat, Ws, Score] = binzsearch(zi_l, zi_u , Z, FMat, Ws,...
    Score, depth, bindepthlimit, options, X, Y, featuresteps, zsteps)

    [m n] = size(X);
    
    % Check the stopping condition
    if length(Z) >= zsteps || sum(ismember(1:(m-1), sum(FMat,2))) == m-1         
        return;
    end
    z_l = Z(zi_l);
    z_u = Z(zi_u);
    if abs(z_u - z_l) <= 1e-4
        return;
    end
    
    z_m = (z_l + z_u)/2;

    options.z = z_m ; 
    options.W0 = options.zinitWfunc(m, options.z, options.seed);
    [WHat, f] = options.wlearner(X,Y, options);
    % ** Assume wlearner the f value of objective function (minimization)
    Score(end+1) = -f; 
    rList = options.wranker(WHat);
    FMat(end+1, rList) = true;
    Ws{end+1} = WHat;

    Z(end+1) = z_m;
    zi_m = length(Z);
    
    K = sum(FMat,2);
    if K(zi_m) - K(zi_l) > featuresteps && depth < bindepthlimit
        [Z, FMat, Ws, Score] = binzsearch(zi_l, zi_m , Z, FMat, Ws, Score, depth+1 ...
            , bindepthlimit, options, X,Y, featuresteps, zsteps);
    end
    if K(zi_u) - K(zi_m) > featuresteps && depth < bindepthlimit
        [Z, FMat, Ws, Score] = binzsearch(zi_m, zi_u , Z, FMat, Ws, Score, depth+1 ...
            , bindepthlimit, options, X,Y, featuresteps, zsteps);
    end
    
end



