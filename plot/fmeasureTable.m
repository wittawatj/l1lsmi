function fmeasureTable( exp, inDatas, inMethods, alpha, dest,renew)
% 
% Table results for artificial datasets. 
% 
if nargin < 6
    renew = false;
end
if nargin < 5
    dest = sprintf('exp/exp%d/exp%d_fmeasure.csv', exp, exp);
end
if nargin < 4
    alpha = 0.05;
end
if nargin < 3  || isempty(inMethods)
    
    inMethods = {'pc', 'fohsic', 'folsmi', 'bahsic', 'balsmi', 'pghsic' ,...
     'pglsmi', 'mrmr', 'qpfs', 'lasso', 'relief'};
end
if nargin < 2  || isempty(inDatas)
    
    inDatas = {'andor', 'sca3', 'xor'};
end

cacheName = 'fmeasure_cells.mat';
cacheFile = sprintf('exp/exp%d/%s', exp, cacheName);
if renew || ~exist(cacheFile, 'file')
    
    % FM is data x methods
    [FM, DataInd, MetInd, n]= fmeasureCells( exp, inDatas, inMethods);
    save(cacheFile, 'FM', 'DataInd', 'MetInd', 'n');
else
    load(cacheFile);
end

% Cell legends
CMets = MetInd.keys();
CInd = MetInd.values();
[V I] = sort(cell2mat(CInd));
CL = CMets(I);

% Sort method header by methodOrder()
MO = methodOrder();
Order = cellfun(@(k)(MO(k)), CL);
[SO, SI] = sort(Order);
CL = CL(SI);
FM = FM(:, SI);

% Map labels to names in the paper
labelmap = labelMapper();
Methods = cellfun(@(k)(labelmap(k)), CL, 'UniformOutput', false);

% Dataset labels
CDatas = DataInd.keys();
CDInd = DataInd.values();
[V I] = sort(cell2mat(CDInd));
CDL = CDatas(I);
Datas = cellfun(@(name)(artMap(name)), CDL, 'UniformOutput', false);

%%%%%% Plot %%%%%%
Mean = cellfun(@mean, FM);
Std = cellfun(@std, FM);

% Statistical test
DMF = cell2dmf(FM);
BestMat = dmetest( -DMF, alpha ); % In dmetest lower is better.

Trials = cellfun(@(E)(sum(~isnan(E))), FM);

% Get win count for each method
Wins = getWinCounts(Mean, Std);

% Get * counts. => The number of times each method performs the best (based
% on the statistical test)
Tops = sum(BestMat,1);

% Export. Create a cell matrix of string outputs. 

Dat = arrayfun(@cellstrfunc, ...
    Mean, Std, Trials, BestMat, 'UniformOutput', false );
Cell = [{''}, Methods; ...
    Datas' Dat ; ...
    {'Wins'}, num2cell(Wins);...
    {'Tops'}, num2cell(Tops);...
    {'fmeasure on artificial data'}, cell(1,size(Dat,2))];

cell2csv(dest, Cell, ';');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


function s=cellstrfunc(m,sd,r, top)
    if top
        topstr = '*';
    else
        topstr = '';
    end
    
    if ~isnan(m)
        % eliminate the leading 0 of SD
        sd_str = sprintf('%1.2f', sd);
        sd_str = regexprep(sd_str, '(0)([.]\d+)', '$2');
        s = sprintf('%s%1.2f (%s, %d)',topstr, m,sd_str,r);
    else
        s = '--';
    end
end

function DMF = cell2dmf(FM)
% 
% Convert a cell matrix of fmeasure arrays into DMF (data x method x fmeasure) 
% matrix. 
%
    [da, me] = size(FM);
    fl = length(FM{1});
    DMF = reshape([FM{:}], [fl, da, me]);
    DMF = permute(DMF, [2 3 1]);

end


function Wins = getWinCounts(Mean, Std)
%
% Get the number of win counts for each method
%
    Mean(isnan(Mean)) = inf;
    Wins = zeros(1, size(Mean,2));
    for i=1:length(Wins)
        W = bsxfun(@(a,b)(a > b), Mean(:,i), Mean); % higher fmeasure is better
        Wins(i) = sum(W(:));
    end
end
