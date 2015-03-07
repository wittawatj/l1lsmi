function mergeTrials( exp, datasetPrefixes, methodPrefixes )
%
% Merge trial files into one file for each method-dataset pair.
% Prefix the result file with tm_...
%
if nargin < 3
    methodPrefixes = {'mrmr', 'relief', 'pc', 'pghsic', 'pglsmi', 'lasso'};
end

if nargin < 2
    datasetPrefixes = [num2cell(char('0'+(0:9)) ), num2cell([char('a'+ (0:25)), char('A'+ (0:25))])];
end

% methodFilter = @(met)(any(cellfun(@(m)(isequal(m, regexprep(met, '(.+)_cv', '$1'))), methodPrefixes)));
methodFilter = @(met)(any(cellfun(@(pat)(any(strfind(regexprep(met, ...
     '(.+)_cv', '$1'), pat)==1)) , methodPrefixes) ));
% dataFilter = @(da)(any(cellfun(@(m)(isequal(m, da)), datasetPrefixes)));
dataFilter = @(da)(any(cellfun(@(pat)(any(strfind(da, pat)==1)), ...
    datasetPrefixes) ));

expFolders = dir(sprintf('exp/exp%d/*-*', exp));

for ei=1:length(expFolders)
    combfolder = expFolders(ei);

    Sep = regexp(combfolder.name, ...
        '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)', 'names');
    method = Sep.method;
    dataset = Sep.data;
    
    if combfolder.isdir && dataFilter(dataset) && methodFilter(method)

        trialFiles = dir(sprintf('exp/exp%d/%s/*-*.mat', exp, combfolder.name));
        if isempty(trialFiles)
            continue;
        end
        maxtrial = getMaxTrials(trialFiles);

        % things to save
        C_Gaussreg = cell(maxtrial, 1);
        C_Svr = cell(maxtrial, 1);
        C_Knn = cell(maxtrial, 1);
        C_Svc = cell(maxtrial, 1);
        
        C_S = cell(maxtrial, 1);
        C_Y = cell(maxtrial, 1);
        C_learneropts = cell(maxtrial, 1);
%         C_o = cell(maxtrial, 1);
        C_savetime = cell(maxtrial, 1);
        FT = [];
        Timecpu = nan(maxtrial, 1);
        Timetictoc = nan(maxtrial, 1);
        
        for fi=1:length(trialFiles)
            tFile = trialFiles(fi);
            fname = tFile.name;

            tfilepath = sprintf('exp/exp%d/%s/%s', exp, combfolder.name, fname);
            L = load(tfilepath);
            %display(sprintf('Loaded %s', tfilepath));
            
            t = L.trial;
            if isfield(L, 'Svr')
                C_Gaussreg{t} = L.Gaussreg;
                C_Svr{t} = L.Svr;
                
            else
                C_Knn{t} = L.Knn;
                C_Svc{t} = L.Svc;
            end
            if isfield( L.S, 'ZTLogs')
                % take too much memory to store (contain handles)
                L.S = rmfield(L.S, 'ZTLogs');
            end
            C_S{t} = L.S;
            C_Y{t} = L.Y;
            C_learneropts{t} = L.learneropts;
%             C_o{t} = L.o;
            C_savetime{t} = L.savetime;
            FT(t,:) = L.S.F;
            Timecpu(t) = L.S.timecpu;
            Timetictoc(t)  = L.S.timetictoc;
        end
        % write the merged results
        dest = sprintf('exp/exp%d/tm_%s.mat', exp, combfolder.name);
        vars = {'C_S', 'C_Y', 'C_learneropts', 'C_savetime', ...
            'FT', 'Timecpu', 'Timetictoc'};
        if isfield(L, 'Svr')
            vars = [vars, {'C_Gaussreg', 'C_Svr'}];
        else
            vars = [vars, {'C_Knn', 'C_Svc'}];
        end
        save(dest, vars{:});
        display(sprintf('Merged to: %s', dest));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function m =getMaxTrials(trialFiles)
    m =0;
    for fi=1:length(trialFiles)
        tFile = trialFiles(fi);
        fname = tFile.name;
        TSep = regexp(fname, ...
           '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)[-](?<trial>\d+)', 'names');
        trial = str2num(TSep.trial);
        if trial > m
            m = trial;
        end
    end
end

