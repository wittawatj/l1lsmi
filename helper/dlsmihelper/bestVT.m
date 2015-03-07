function VT = bestVT(VTV, k)
% 
% Try to find best v and its ranked features. 
% If there exists a v which gives exactly k features, then return it.
% If no such v, find v which gives less than k features (closest to k, 
% lowest f value).
% 
    
    Lfeatures = cellfun(@length, {VTV.rankList});
    F = [VTV.f];
    V = [VTV.v];
    [Y I] = sortrows([abs(k - Lfeatures)', (Lfeatures-k)', F', V'], [1 2 3 4]);
    VT = VTV(I(1));
end


