function [ZT, ZTLog] = ztuner_seq(X, Y, options)
% 
% Tune z (l1 ball width) from low to high. Stop when k features are found.
% This is recommended over tuning from high to low since W may approach
% infinity when v is high. Also, typically k is low. So starting from
% low z makes sense.
% 
error('Use ztuner_seq_radius');
[m, n] = size(X);

% Intializer for W
zinitWfunc = myProcessOptions(options, 'zinitWfunc', @zinitW);

% wlearner = function which learns W. f: (X,Y,options) -> [W, fvalue].
wlearner = options.wlearner;

% k = number of features to select
k = options.k;

% wranker = function which returns a ranked list of m features. f: W ->
% rank_list. rank_list may have length less than m.
wranker = options.wranker; 

z_min = myProcessOptions(options, 'z_min', 1e-2);
zsteps = myProcessOptions(options, 'zsteps', 15);
% Limit on Binary search steps
zbinsteps = myProcessOptions(options, 'zbinsteps', 10);

ZTV = struct(); % struct array
ZTLog = struct(); % global struct
ZTLog.options = options;

z = z_min;

giveup = true;
% Try to find exactly k features or less than k features
for zi=1:zsteps
    options.z = z;
    options.W0 = zinitWfunc(m, z, options.seed);
    fprintf('%s: z: %.3e\n', mfilename, z);
    [W,f] = wlearner(X,Y,options);
    rList = wranker(W);
    % Logging
    ZTV(zi).W = W;
    ZTV(zi).z = z;
    ZTV(zi).f = f;
    ZTV(zi).rankList = rList;
    if length(rList) == k
        % Found exactly k features
        ZT = ZTV(zi);
        ZTLog.ZTV = ZTV;
        return;
    elseif length(rList) > k
        giveup = false;
        break;
    end
    z = 2*z;
end

if giveup 
    % Give up because so many z were tried but cannot find z which gives
    % more than k features
    ZT = bestZT(ZTV, k);
    ZTLog.ZTV = ZTV;
    return;
end

% More than k features are found
% Use binary search to backtrack z

% upper bound of z is the latest z found to give more than k features
% Further extend z a bit more with 1.5 factor since high z does not always 
% gives higher number of features than low z.
z_h = z*1.5; 
z_l = z_h/(2*1.5);

zi = length(ZTV) + 1;
for i=1:zbinsteps
    z = (z_h + z_l)/2;
    options.z = z;
    options.W0 = zinitWfunc(m, z, options.seed);
    fprintf('%s: z: %.3e\n', mfilename, z);
    [W,f] = wlearner(X,Y,options);
    rList = wranker(W);
    % Logging
    ZTV(zi).W = W;
    ZTV(zi).z = z;
    ZTV(zi).f = f;
    ZTV(zi).rankList = rList;
    l = length(rList); 
    if l == k
        % Found exactly k features
        ZT = ZTV(zi);
        ZTLog.ZTV = ZTV;
        return;
    elseif l < k
        z_l = z;
        
    else % l > k
        z_h = z;
    end
    zi = zi + 1;
    if abs(z_h - z_l) < 1e-5
        break;
    end
end

ZT = bestZT(ZTV, k);
ZTLog.ZTV = ZTV;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


