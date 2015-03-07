function nFMeasurePlot( Exps, dataname )
% 
% Plot where x-axis is the datasize, and y-axis
% is the f-measure for the specified artificial data. 
% One line in the plot corresponds to one method. 
% 
% Assume n in the same exp is equal for all methods.
% 


if length(Exps) <= 1
	error('%s: Exps should contain at leasts 2 exp numbers.', mfilename);
end

% x-axis (data size)
dataSize = zeros(length(Exps),1);
% y-axis (f-measure scores) (length(Exps) x methods)
FM = cell(length(Exps), 1);
% Map method to index
MetInd = containers.Map();

for ei=1:length(Exps)
    exp = Exps(ei);
    metFolders = dir(sprintf('exp/exp%d/%s-*', exp, dataname));
    for mi=1:length(metFolders)
        mfolder = metFolders(mi);
        % Keep method index
        Sep = regexp(mfolder.name, ...
            '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)','names');
        method = Sep.method;
        % Simplify method name
        method = regexprep(method, '_.*','');
        
        MetInd = addToMap(MetInd, method);
        
        assert(mfolder.isdir);
        trialFiles = dir(sprintf('exp/exp%d/%s/*.mat', exp, mfolder.name));
        
        FMeasures = zeros(length(trialFiles),1);
        for fi=1:length(trialFiles)
            tFile = trialFiles(fi);
            fname = tFile.name;
            tfilepath = sprintf('exp/exp%d/%s/%s', exp, mfolder.name, fname);
            load(tfilepath);
            % Record datasize
            dataSize(ei) = size(X,2);
            
            FMeasures(fi) = getFMeasure(D, S);
        end
        FM{ei, MetInd(method)} = FMeasures;
    end
end

% Cell legends
CMets = MetInd.keys();
CInd = MetInd.values();
[V I] = sort(cell2mat(CInd));
CL = CMets(I);

% Plot
Mean = cellfun(@mean, FM);
Std = cellfun(@std, FM);
figure
hold on
plotstyles
for mi=1:length(CL)
    errorbar(dataSize, Mean(:,mi), Std(:,mi), PlotStyle{mi},...
        'MarkerSize', 6, 'LineWidth', 3);
%     plot(dataSize, Mean(:,mi), PlotStyle{mi}, 'MarkerSize', 6, ...
%         'LineWidth', 4);
end
legend(CL, 'Interpreter','none');
fontsize = 18;
xlabel('Sample size','FontSize', fontsize);
ylabel('F-measure','FontSize', fontsize);
title(sprintf('F-measure on dataset: %s', dataname),...
    'FontSize', fontsize);
hold off
grid on
dataSize
set(gca, 'FontSize', 18);
set(gca, 'XTick', dataSize);
% set(gca, 'YLim', [0 1]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function M = addToMap(M, k)
    if ~M.isKey(k)
        ind = length(M) + 1;
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
    f = 2*p*r/(p+r);

end