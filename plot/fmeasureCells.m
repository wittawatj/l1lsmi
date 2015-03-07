function [FM, DataInd, MetInd, n]= fmeasureCells( exp, inDatas, inMethods)
% 
% Table results for artificial datasets. 
% 

if nargin < 2  || isempty(inDatas)
    inDatas = {};
end

if nargin < 3  || isempty(inMethods)
    inMethods = {};
end


% f-measure scores (datasets x methods)
FM = cell(1, 1);

% Map method to index
MetInd = containers.Map();
% Map dataset to index
DataInd = containers.Map();

expFolders = dir(sprintf('exp/exp%d/*-*', exp));

methodFilter = @(met)(any(cellfun(@(pat)(any(strfind(met, pat)==1)) , ...
        inMethods)));
% dataFilter = @(met)(any(cellfun(@(pat)(any(strfind(met, pat)==1)) , ...
%     inDatas)));
% methodFilter = @(met)(any(cellfun(@(m)(isequal(m, met)), inMethods)));
dataFilter = @(dat)(any(cellfun(@(d)(isequal(d, dat)), inDatas)));


for ei=1:length(expFolders)
    combfolder = expFolders(ei);
    % Keep method and dataset index
    Sep = regexp(combfolder.name, ...
        '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)', 'names');
    method = Sep.method;
    dataset = Sep.data;
    
    if ~(methodFilter(method) && dataFilter(dataset))
        continue;
    end
    
    % Simplify method name
%     method = regexprep(method, '_.*','');
    MetInd = addToMap(MetInd, method);
    DataInd = addToMap(DataInd, dataset);

    assert(combfolder.isdir);
    trialFiles = dir(sprintf('exp/exp%d/%s/*.mat', exp, combfolder.name));

    FMeasures = zeros(length(trialFiles),1);
    for fi=1:length(trialFiles)
        tFile = trialFiles(fi);
        fname = tFile.name;
        tfilepath = sprintf('exp/exp%d/%s/%s', exp, combfolder.name, fname);
        load(tfilepath);
        
%         datagen_func = str2func(data_gen_func_str);
        if ~exist('n', 'var')
            n = 400;
            display('n cannot be determined. assume n=400.');
        end
        
        FMeasures(fi) = getFMeasure(D, S); % S is from loading
    end
    FM{DataInd(dataset), MetInd(method)} = FMeasures;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function M = addToMap(M, k)
    if ~M.isKey(k)
        ind = length(M) + 1;
        
        M(k) = ind;
    end
end


function M = addToMapMethod(M, k)
    if ~M.isKey(k)
        MO = methodOrder();
        if MO.isKey(k)
            ind = MO(k);
        else
            ind = 100 + length(M);
        end
        
        M(k) = ind;
    end
end

        
function f = getFMeasure(D, S)
% D is the correct feature set (cell array)
% S is the feature selection result struct
% 
    F = logical(S.F);
    Correct = false(1, length(F));
    Correct(D{1}) = true;
    
    % precision
    tp = sum(and(Correct, F)); 
    p = tp / sum(F);
    % recall
    r = tp / length(D{1});
    
    num = 2*p*r;
    if num ==0
        f = 0;
    else
        f = num/(p+r);
    end
    
end