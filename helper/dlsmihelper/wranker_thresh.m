function rankList = wranker_thresh( W, threshold)
% 
% Ranks features with absolute values of W
% Features with absolute values below the specified threshold are
% not included in the returning list. 
% 
    absW = abs(W);
    [V, rank_list] = sort(absW, 'descend');
    I = V >= threshold;
    rankList = rank_list(1:sum(I));

end

