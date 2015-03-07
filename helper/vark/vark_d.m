function  VK = vark_d(X, Y, options )
%
% General vark function for dlsmi and dhsic.
%
[m n] = size(X);

t0 = cputime;
tic;

seed = myProcessOptions(options,'seed', 1);

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed', seed);
RandStream.setDefaultStream(rs);          

% Initializer of W. The number of columns is used as the number of repeats.
% ones(m,1) is a good heuristic for initializing W.
initWs = myProcessOptions(options, 'initWs', [ones(m,1), rand(m,4)] );
repeats = size(initWs,2);

seedlist = randi([1e4, 1e7], 1, repeats);

Vs = cell(1, repeats);
FMats = cell(1, repeats);
Wss = cell(1, repeats);
Scores = cell(1, repeats);
for i=1:length(seedlist)
    seed = seedlist(i);
    options.seed = seed;
    options.W0 = initWs(:,i);
    fprintf('%s: seed: %.3g\n', mfilename, seed);
    
    % There could be two different v's which give the same number of selected
    % features.
    [V, FMat, Ws, Score] = funcAllVBin(X, Y, options);

    Vs{i} = V;
    FMats{i} = FMat;
    Wss{i} = Ws;
    Scores{i} = Score;
end

% Eliminate the cases in which two different v's give the same number of
% features. Keep the one with higher score. Also merge all results from
% many repeats.
[V, FMat, Ws, Score] = bestVForEachK(Vs, FMats, Wss, Scores);

timetictoc = toc;
timecpu = cputime - t0;

VK.timetictoc = timetictoc;
VK.timecpu = timecpu;

Raw.Vs = Vs;
Raw.FMats = FMats;
Raw.Wss = Wss;
Raw.Scores = Scores;

VK.Raw = Raw;
VK.Score = Score;
VK.FMat = FMat;
VK.V = V;
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

function [NV, NFMat, NWs, NScore] = bestVForEachK(Vs, FMats, Wss, Scores)

    % Merge results from many repeats
    V = vertcat(Vs{:});
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
        
        iV = V(Ind);
        iFMat = FMat(Ind, :);
        iWs = Ws(Ind, :);
        iScore = Score(Ind);
                    
        % Choose the one with the highest score
        % If score is equal, prefer high v.
        [Sorted, RI] = sortrows([iScore iV], [-1 -2]);
        chosen = RI(1);

        NV(ki) = iV(chosen);
        NFMat(ki,:) = iFMat(chosen,:);
        NWs(ki,:) = iWs(chosen, :);
        NScore(ki) = iScore(chosen);
        
    end
    
end


