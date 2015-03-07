function  exportResults( exp, maxtrials, expression, alpha, dest)
%
% Export results to CSV. The expFolder has to contain one folder for
% each method-dataset pair. In side the folder, the result of one trial
% is contained in one file.
%
% expression is a Matlab's expression string used to retrieve 
% information in each trial file. 
%
% alpha is the significance level for paired T-test
%
if nargin < 3
    expression = 'svc_svr_err';
end

if nargin < 4
    alpha = 0.05;
end

if nargin < 5
    dest = [];
end

    
% Map method to index
MetInd = containers.Map();
% Map dataset to index
DataInd = containers.Map();

expFolders = dir(sprintf('exp/exp%d/*-*', exp));

% Errors of all (data x method pairs)
Errs = cell(1,1);

for ei=1:length(expFolders)
    combfolder = expFolders(ei);
    if combfolder.isdir
        % Keep method and dataset index
        Sep = regexp(combfolder.name, ...
            '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)', 'names');
        method = Sep.method;
        dataset = Sep.data;

        MetInd = addToMap(MetInd, method);
        DataInd = addToMap(DataInd, dataset);

        trialFiles = dir(sprintf('exp/exp%d/%s/*-*.mat', exp, combfolder.name));

    %     DMErr = nan(length(trialFiles),1);
        DMErr = nan(maxtrials, 1);
        for fi=1:length(trialFiles)
            tFile = trialFiles(fi);
            fname = tFile.name;
            TrialSep = regexp(fname, '(\w+?)[-](\w+?)[-](?<trial>\d+)[.]mat', 'names');
            trial = str2double(TrialSep.trial);
            if trial <= maxtrials
                tfilepath = sprintf('exp/exp%d/%s/%s', exp, combfolder.name, fname);
        %         load(tfilepath);

                % get data from the loaded trial file
                DMErr(trial) = eval(sprintf('%s(''%s'')', expression, tfilepath) ) ;
            end
        end
        Errs{DataInd(dataset), MetInd(method)} = DMErr;
    end
end

Errs = fillNans(Errs, maxtrials);
% Cell legends
CMets = MetInd.keys();
CInd = MetInd.values();
[V I] = sort(cell2mat(CInd));
MetHeader = CMets(I);

% Sort method header by methodOrder()
MO = methodOrder();
Order = cellfun(@(k)(MO(k)), MetHeader);
[SO, SI] = sort(Order);
MetHeader = MetHeader(SI);
Errs = Errs(:, SI);

% Dataset labels
CDatas = DataInd.keys();
CDInd = DataInd.values();
[V I] = sort(cell2mat(CDInd));
DataHeader = CDatas(I);


% Statistical test
DME = cell2dme(Errs);
BestMat = dmetest( DME, alpha );

Mean = cellfun(@nanmean, Errs);
Std = cellfun(@nanstd, Errs);
Trials = cellfun(@(E)(sum(~isnan(E))), Errs);

% Get win count for each method
Wins = getWinCounts(Mean, Std);

% Get * counts. => The number of times each method performs the best (based
% on the statistical test)
Tops = sum(BestMat,1);

LM = labelMapper();
MetHeader = cellfun(@(m)(LM(m)), MetHeader, 'UniformOutput' ,false);
% Export. Create a cell matrix of string outputs. 
% cellStrFuncs = {@cellstrfunc, @cellstrfunc_mean, @cellstrfunc_sd};
Dat = arrayfun(@cellstrfunc, ...
    Mean, Std, Trials, BestMat, 'UniformOutput', false );
Cell = [{''}, MetHeader ; ...
    DataHeader' Dat ; ...
    {'Wins'}, num2cell(Wins);...
    {'Tops'}, num2cell(Tops);...
    {expression}, cell(1,size(Dat,2))];

if isempty(dest)
    dest = sprintf('exp/exp%d/exp%d_%s.csv', exp, exp, expression);
end
cell2csv(dest, Cell, ';');

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


function [bestErr, bestStd] = getBestErr(Mean, Std)
    [bestErr, I] = nanmin(Mean, [], 2);
    bestStd = arrayfun(@(r,c)(Std(r,c)), 1:length(I), I' );
    bestStd = bestStd(:);
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


function s=cellstrfunc_mean(m,sd,r, top)
    
    if ~isnan(m)
        s = sprintf('%f',m);
    else
        s = '--';
    end
end

function s=cellstrfunc_sd(m,sd,r, top)
    s = sprintf('%f',sd);
end

function s=cellstrfunc_trials(m,sd,r, top)
    
    s = sprintf('%d', r);
end

function s=cellstrfunc_top(m,sd,r, top)
    if top
        topstr = '*';
    else
        topstr = '';
    end
    s = sprintf('%s', topstr);
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



function r = abs_redun_rate(trialFile)
   % This is used for the 'expression' argument
   load(trialFile);
   r = S.abs_redun_rate;
   
end

function r = redun_rate(trialFile)
   % This is used for the 'expression' argument
   load(trialFile);
   r = S.redun_rate;
   
end


function t = timecpu(trialFile)
   % This is used for the 'expression' argument
   load(trialFile);
   fprintf('Loaded %s\n', trialFile);
   t = S.timecpu;
   
end



function err = svc_svr_err(trialFile)
   % This is used for the 'expression' argument
   load(trialFile);
   fprintf('Loaded %s\n', trialFile);
   if exist('Svc', 'var')
       err = Svc.libsvm_err;
   else
       err = Svr.libsvm_err;
   end
    
end


function err = knn_gaussreg_err(trialFile)
   % This is used for the 'expression' argument
   load(trialFile);
   fprintf('Loaded %s\n', trialFile);
   if exist('Knn', 'var')
       err = Knn.knn_err;
   else
       err = Gaussreg.gaussreg_err;
   end
   
end