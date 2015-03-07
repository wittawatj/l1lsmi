function  exportTrialsResults( exp, maxtrials, options)
%
% Export results to CSV. The expFolder has to contain one trial-merged 
% (tm_...mat) file for each method-dataset pair. See mergeTrials.m
% 
% options is a struct
%
error('Just copied from smit. Modify it first.');
if nargin < 3
    options = [];
end
% , expression, ...
%     datasetPrefixes, methodPrefixes, alpha, dest, datasetEqual, methodEqual

methodEqual = myProcessOptions(options, 'methodEqual', false);

% false means => use prefix
% true means => use exact match
datasetEqual = myProcessOptions(options, 'datasetEqual', false);

dest = myProcessOptions(options, 'dest', []);
alpha = myProcessOptions(options, 'alpha', 0.05);

methodPrefixes = myProcessOptions(options, 'methodPrefixes' , ...
    {'klogis_ent', 'logis_ent', 'klogis_exp',...
        'logis_exp', 'smit_mad', 'smit_msd', 'smit_mad_lfp', 'smit_msd_lfp'});

datasetPrefixes = myProcessOptions(options, 'datasetPrefixes', ...
    [num2cell(0:9), num2cell([char('a'+ (0:25)), char('A'+ (0:25))])]);

expression = myProcessOptions(options, 'expression', 'cerr');
    
% True to use standard error instead of standard deviation
use_se = myProcessOptions(options, 'use_se', false);

% multiply by 100 the values
time100 = myProcessOptions(options, 'time100', false);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
if methodEqual
    methodFilter = @(met)(any(cellfun(@(m)( isequal(m, regexprep(met, '(.+)_cv', '$1'))),...
 methodPrefixes)));
else
    methodFilter = @(met)(any(cellfun(@(pat)(any(strfind(regexprep(met, ...
     '(.+)_cv', '$1'), pat)==1)) , methodPrefixes) ));
end
 
if datasetEqual
    dataFilter = @(da)(any(cellfun(@(m)(isequal(m, da)), datasetPrefixes)));
else
    dataFilter = @(da)(any(cellfun(@(pat)(any(strfind(da, pat)==1)), ...
    datasetPrefixes) ));
end


% Map method to index
MetInd = containers.Map();
% Map dataset to index
DataInd = containers.Map();

tmFiles = dir(sprintf('exp/exp%d/tm_*-*.mat', exp));

% Values (e.g. errors) of all (dataxmethod pairs)
DMValues = cell(1,1);
for fi=1:length(tmFiles)
    
    % Keep method and dataset index
    Sep = regexp(tmFiles(fi).name, ...
        'tm_(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)',...
        'names');
    method = Sep.method;
    method = regexprep(method, '(.+?)_cv', '$1');
    dataset = Sep.data;
    
    if dataFilter(dataset) && methodFilter(method)
        MetInd = addToMap(MetInd, method);
        DataInd = addToMap(DataInd, dataset);

        tmPath = fullfile('exp', sprintf('exp%d', exp), tmFiles(fi).name);
        
        EValues = eval(sprintf('%s(''%s'')', expression, tmPath));
        Values = nan(maxtrials, 1);
%         Values(1:length(EValues)) = EValues;
        l = min(maxtrials, length(EValues));
        Values(1:l) = EValues(1:l);
        % use percentage
        if time100
            time = 100;
        else
            time = 1;
        end
        DMValues{DataInd(dataset), MetInd(method)} = Values*time;
    end
end

% Cell legends
CMets = MetInd.keys();
CInd = MetInd.values();
[V I] = sort(cell2mat(CInd));
MetHeader = CMets(I);

% Dataset labels
CDatas = DataInd.keys();
CDInd = DataInd.values();
[V I] = sort(cell2mat(CDInd));
DataHeader = CDatas(I);

% Sort methods according to method order
MethodOrder = methodOrder();
Order = cellfun(@(m)(MethodOrder(m)), MetHeader);
[SO, SOI] = sort(Order);
MetHeader = MetHeader(SOI);

% Sort DMValues
DMValues = DMValues(:, SOI);

% Translate method labels
MLM = methodLabelMap();
MetHeader = cellfun(@(m)(MLM(m)), MetHeader, 'UniformOutput', false);

% Statistical test
DMValues = fillNans(DMValues, maxtrials);
DME = cell2dme(DMValues);
BestMat = dmetest( DME, alpha );

Mean = cellfun(@nanmean, DMValues);
Std = cellfun(@nanstd, DMValues);
Trials = cellfun(@(E)(sum(~isnan(E))), DMValues);

% Get win count for each method
Wins = getWinCounts(Mean, Std);

% Get * counts. => The number of times each method performs the best (based
% on the statistical test)
Tops = sum(BestMat,1);

% Export. Create a cell matrix of string outputs. 
if use_se
    display_func = @cellstrfunc_se;
else
    display_func = @cellstrfunc;
end

Dat = arrayfun(display_func, ...
    Mean, Std, Trials, BestMat, 'UniformOutput', false );
Cell = [{''}, MetHeader ; ...
    DataHeader' Dat ; ...
    {'Wins'}, num2cell(Wins);...
    {'Tops'}, num2cell(Tops);...
    {expression}, cell(1,size(Dat,2))];

if isempty(dest)
    dest = sprintf('exp/exp%d/exp%d_trials_rho.csv', exp, exp);
end
cell2csv(dest, Cell, ';');

display(sprintf('CSV written to: %s', dest));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


function Errs = fillNans(Errs, maxtrials)
    [r c] = size(Errs);
    for i=1:r
        for j=1:c
            if isempty(Errs{i,j})
                Errs{i,j} = nan(maxtrials, 1);
            end
        end
    end
end

function Wins = getWinCounts(Mean, Std)
%
% Get the number of win counts for each method
%
    Mean(isnan(Mean)) = inf;
    Wins = zeros(1, size(Mean,2));
    for i=1:length(Wins)
        W = bsxfun(@(a,b)(a<b), Mean(:,i), Mean);
        Wins(i) = sum(W(:));
    end
end

function M = addToMap(M, k)
    if ~M.isKey(k)
        ind = length(M) + 1;
        M(k) = ind;
    end
end

function DME = cell2dme(Errs)
% 
% Convert a cell matrix of err arrays into DME (data x method x errs) 
% matrix. 
%
    [da, me] = size(Errs);
    er = length(Errs{1});
    DME = reshape([Errs{:}], [er, da, me]);
    DME = permute(DME, [2 3 1]);

end

function s=cellstrfunc_se(m,sd,r, top)
%
% Display standard error (standard deviation/sqrt(#trial)) instead of 
% standard deviation
%
    if top
        topstr = '*';
    else
        topstr = '';
    end
    
    if ~isnan(m)
        s = sprintf('%s%1.3f (%1.3f, %d)',topstr, m,sd/sqrt(r), r);
    else
        s = '--';
    end
end


function s=cellstrfunc(m,sd,r, top)
    if top
        topstr = '*';
    else
        topstr = '';
    end
    
    if ~isnan(m)
        s = sprintf('%s%2.2f (%1.2f, %d)',topstr, m,sd,r);
%         s = sprintf('%s%1.3g (%1.2g, %d)',topstr, m,sd,r);
    else
        s = '--';
    end
end


function E=cerr(tmPath)
    load(tmPath);
    display(sprintf('Loaded: %s', tmPath));
    E=Cerr;
end


function E=timecpu(tmPath)
    load(tmPath);
    display(sprintf('Loaded: %s', tmPath));
    E=Timecpu;
end


function E=timetictoc(tmPath)
    load(tmPath);
    display(sprintf('Loaded: %s', tmPath));
    E=Timetictoc;
end
