function  VK = vark_pg(X, Y, options )
%
% General vark function for pg functions.
% The main parameter to vary is z (l1 ball's radius).
%
[m n] = size(X);

t0 = cputime;
tic;

seed = myProcessOptions(options,'seed', 1);

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed', seed);
RandStream.setDefaultStream(rs);          

% Number of restarts
ztuner_repeat = myProcessOptions(options, 'ztuner_repeat', 5);
repeats = ztuner_repeat;

seedlist = randi([1e4, 1e7], 1, repeats);

Zs = cell(1, repeats);
FMats = cell(1, repeats);
Wss = cell(1, repeats);
Scores = cell(1, repeats);
for i=1:length(seedlist)
    seed = seedlist(i);
    options.seed = seed;
    fprintf('%s: seed: %.3g\n', mfilename, seed);
    
    % There could be two different v's which give the same number of selected
    % features.
    [Z, FMat, Ws, Score] = funcAllZBin(X, Y, options);

    Zs{i} = Z;
    FMats{i} = FMat;
    Wss{i} = Ws;
    Scores{i} = Score;
end

% Eliminate the cases in which two different z's give the same number of
% features. Keep the one with higher score. Also merge all results from
% many repeats.
[Z, FMat, Ws, Score] = bestZForEachK(Zs, FMats, Wss, Scores);

timetictoc = toc;
timecpu = cputime - t0;

VK.timetictoc = timetictoc;
VK.timecpu = timecpu;

Raw.Zs = Zs;
Raw.FMats = FMats;
Raw.Wss = Wss;
Raw.Scores = Scores;

VK.Raw = Raw;
VK.Score = Score;
VK.FMat = FMat;
VK.Z = Z;
VK.Ws = Ws;

% Calculate the redundancy rate of the selected features
SumK = sum(FMat,2);
if max(SumK) > 6000
    return;
end

AbsRedunRate = nan(size(FMat,1), 1);
RedunRate = nan(size(FMat,1), 1);

Rho = corrcoef(X'); % full correlation matrix
for i=1:size(FMat,1)
    F = logical(FMat(i,:));
    selected = sum(F);
    if selected <= 1
        RedunRate(i) =  0;
        AbsRedunRate(i) = 0;
    else
        SubRho = Rho(F,F);
        SR_corrs = SubRho(logical(tril(ones(selected),-1)));

        RedunRate(i) =  sum(SR_corrs)/(selected*(selected-1));
        AbsRedunRate(i) =  sum(abs(SR_corrs))/(selected*(selected-1));
    end    
end
VK.AbsRedunRate = AbsRedunRate;
VK.RedunRate = RedunRate;


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%
end

function [NV, NFMat, NWs, NScore] = bestZForEachK(Zs, FMats, Wss, Scores)

    % Merge results from many repeats
    Z = vertcat(Zs{:});
    FMat = vertcat(FMats{:});
    Score = vertcat(Scores{:});
    Q = cellfun(@(c)([c{:}]) , Wss, 'UniformOutput' ,false);
    Ws = [Q{:}]';
    
    SK = sum(FMat,2);
    K = unique(SK);
    
    NV = zeros(length(K), 1);
    m = size(FMats{1},2);
    NFMat = zeros(length(K), m);
    NWs = zeros(length(K), m);
    NScore = zeros(length(K),1);
    
    for ki=1:length(K)
        k = K(ki);
        Ind = SK == k;
        
        iZ = Z(Ind);
        iFMat = FMat(Ind, :);
        iWs = Ws(Ind, :);
        iScore = Score(Ind);
                    
        % Choose the one with the highest score
        % If score is equal, prefer high z.
        [Sorted, RI] = sortrows([iScore iZ], [-1 -2]);
        chosen = RI(1);

        NV(ki) = iZ(chosen);
        NFMat(ki,:) = iFMat(chosen,:);
        NWs(ki,:) = iWs(chosen, :);
        NScore(ki) = iScore(chosen);
        
    end
    
end


