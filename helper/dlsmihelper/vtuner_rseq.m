function [VT, VTLog] = vtuner_rseq(X, Y, options)
% 
% Tune v from high to low. Stop when k features are found.
% This is recommended over tuning from low to high since W may approach
% infinity when v is low or 0. Also, typically k is low. So starting from
% high v makes more sense. 
% 

% wlearner = function which learns W. f: (X,Y,options) -> [W, fvalue].
wlearner = options.wlearner;

% k = number of features to select
k = options.k;

% wranker = function which returns a ranked list of m features. f: W ->
% rank_list. rank_list may have length less than m.
wranker = options.wranker; 

v_max = myProcessOptions(options,'v_max', 2);

VTV = struct(); % struct array
VTLog = struct(); % global struct
VTLog.options = options;

v = v_max;

giveup = true;
% Try to find exactly k features or less than k features
for vi=1:20
    options.v = v;
    fprintf('%s: v: %.3g\n', mfilename, v);
    [W,f] = wlearner(X,Y,options);
    rList = wranker(W);
    % Logging
    VTV(vi).W = W;
    VTV(vi).v = v;
    VTV(vi).f = f;
    VTV(vi).rankList = rList;
    if length(rList) == k
        % Found exactly k features
        VT = VTV(vi);
        VTLog.VTV = VTV;
        return;
    elseif length(rList) > k
        giveup = false;
        break;
    end
    v = v/2;
end

if giveup 
    % Give up because so many v were tried but cannot find v which gives
    % more than k features
    VT = bestVT(VTV, k);
    VTLog.VTV = VTV;
    return;
end

% More than k features are found
% Use binary search to backtrack v

% lower bound of v is the latest v found to give more than k features
v_l = v;
v_h = v_l*2; 

vi = length(VTV) + 1;
for i=1:5 % Limit to 5 trials
    v = (v_h + v_l)/2;
    options.v = v;
    fprintf('%s: v: %.3g\n', mfilename, v);
    [W,f] = wlearner(X,Y,options);
    rList = wranker(W);
    % Logging
    VTV(vi).W = W;
    VTV(vi).v = v;
    VTV(vi).f = f;
    VTV(vi).rankList = rList;
    l = length(rList); 
    if l == k
        % Found exactly k features
        VT = VTV(vi);
        VTLog.VTV = VTV;
        return;
    elseif l < k
        v_h = v;
%         v_hk = l;
    else % l > k
        v_l = v;
%         v_lk = l;
    end
    vi = vi + 1;
end

VT = bestVT(VTV, k);
VTLog.VTV = VTV;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


