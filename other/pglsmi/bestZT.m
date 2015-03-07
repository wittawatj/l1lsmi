function ZT = bestZT(ZTV, k)
% 
% Try to find best z and its ranked features. 
% If there exists a z which gives exactly k features, then return it.
% If no such z, find z which gives less than k features (closest to k, 
% lowest f value).
% 
    
    Lfeatures = cellfun(@length, {ZTV.rankList});
    F = [ZTV.f];
    Z = [ZTV.z];
    [Y I] = sortrows([abs(k - Lfeatures)', (Lfeatures-k)', F', Z'], [1 2 3 -4]);
    ZT = ZTV(I(1));
    
end


