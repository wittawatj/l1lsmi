function plotVvsFeatures(expnum, dataset, ...
    methodPrefixes, restart )
%
% Plot V on x-axis and the number of selected features of Y-axid
% This is only applicable to feature selection algorithms which have v
% (sparseness regularization parameter)
%

if nargin < 4
    restart = 1;
end

if nargin < 3
    methodPrefixes = {'dlsmi', 'dhsic'};
    % filter: begin with one of ...
    
end
% methodFilter = @(met)(any(cellfun(@(m)(isequal(m, met)), methodPrefixes)));

methodFilter = @(met)(any(cellfun(@(pat)(any(strfind(met, pat)==1)) , ...
        methodPrefixes) ));
%Methods = getAllMethods(expNum);
%Methods = cellfun(methodFilter, Methods, 'UniformOutput', false);

PlotData = []; % a struct
Folders  = dir(sprintf('exp%sexp%d%s%s-*', filesep, expnum, filesep, dataset));
for fi=1:length(Folders)
    fname = Folders(fi).name;
    Match = regexp(fname, '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)', 'names');
    met = Match.method;
    
    Trials = getAllTrials(expnum, dataset, met);
    % Use the lowest number of trial available.
    if ~isempty(Trials)
        trial = Trials(1);
        if methodFilter(met)
            % File is the result of the method we want to see
            resultPath = sprintf('exp%sexp%d%s%s-%s', filesep, expnum, ...
                filesep, dataset, met);
            resultFile = fullfile(resultPath, sprintf('%s-%s-%d.mat', ...
                dataset, met, trial));

            load(resultFile)
            fprintf('Loaded %s\n', resultFile);

            VTLog = S.VTLogs{restart};

            % Create plot data
            in = length(PlotData) + 1;
            [SV , Ind] = sort([VTLog.VTV.v])    ;
            PlotData(in).X = SV;
            L = cellfun(@length, {VTLog.VTV.rankList});
            L = L(Ind);
            PlotData(in).Y = L;
            PlotData(in).Method = met;
        end
    end
end

if isempty(PlotData)
    return;
end
% Plot

hold on

linestyles = cellstr(char('-','--','-.','--','-',':','-.','-','--',':','-',':',...
'-.','--','-',':','-.',':','-',':','-.', ...
'-', ':', '--', '-.' , ':', '--' ,'-' ,'-.', '--',':'));


MarkerEdgeColors=['r','b','m','g','c','b','r',...
'b','m','k','c','g','r','b','m','k','c','g',...
'r','c','b','k','g','m','r','b','m','k','c','g','r'];


Markers=['o','d','p','x','s','x','v','^','<','>','+','h','.',...
'+','*','o','x','^','<','h','.','>','p','s','d','v',...
'o','x','+','*','s','d','v','^','<','>','p','h','.'];

for mi=1:length(PlotData)
    PData = PlotData(mi);
    plot(PData.X, PData.Y, [linestyles{mi}, MarkerEdgeColors(mi), Markers(mi)], ...
        'LineWidth', 3, ...
        'MarkerFaceColor', 'k', ...
        'MarkerEdgeColor', MarkerEdgeColors(mi), ...
        'MarkerSize', 7)
end
set(gca,'XScale','log');
set(gca, 'FontSize', 24);

legend({PlotData.Method}, 'Interpreter', 'none')
xlabel('v (l1 regularization parameter)');
ylabel('k (#selected features)');
title(sprintf('%s, Trial: %d, Restart: %d', dataset, trial, restart))
hold off
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

