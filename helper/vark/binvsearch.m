function [V, FMat, Ws, Score] = binvsearch(vi_l, vi_u , V, FMat, Ws,...
    Score, depth, bindepthlimit, options, X,Y, featuresteps, vsteps)

    [m n ] = size(X);
    % Check the stopping condition
    if length(V) >= vsteps || sum(ismember(1:(m-1), sum(FMat,2))) == m-1         
        return;
    end
    v_l = V(vi_l);
    v_u = V(vi_u);
    v_m = (v_l + v_u)/2;

    options.v = v_m ; 

    [WHat, f] = options.wlearner(X,Y, options);
    % ** Assume wlearner the f value of objective function (minimization)
    Score(end+1) = -f; 
    rList = options.wranker(WHat);
    FMat(end+1, rList) = true;
    Ws{end+1} = WHat;

    V(end+1) = v_m;
    vi_m = length(V);
    
    K = sum(FMat,2);
    if K(vi_l) - K(vi_m) > featuresteps && depth < bindepthlimit
        [V, FMat, Ws, Score] = binvsearch(vi_l, vi_m , V, FMat, Ws, Score, depth+1 ...
            , bindepthlimit, options, X,Y, featuresteps, vsteps);
    end
    if K(vi_m) - K(vi_u) > featuresteps && depth < bindepthlimit
        [V, FMat, Ws, Score] = binvsearch(vi_m, vi_u , V, FMat, Ws, Score, depth+1 ...
            , bindepthlimit, options, X,Y, featuresteps, vsteps);
    end
    
end



