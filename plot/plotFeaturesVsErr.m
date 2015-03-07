function  plotFeaturesVsErr( expnum, dataset, methodPrefixes, knngauss, labelmap)
%
% Plot the number of selected features on the x-axis, and 
% prediction's error on y-axis. batchPredictVark must have been used
% before this function can be used. This requires vark results.
%
fontsize = 34;
if nargin < 5
    labelmap = labelMapper();
end

if nargin < 4
    knngauss = false;
end

if nargin < 3
    % filter: begin with one of ...
%     methodPrefixes = {'ba', 'fo', 'pc', 'pg', 'mrmr', 'lasso', 'qpfs'}; 
    methodPrefixes = {'pglsmi', 'pghsic', 'pc', 'mrmr', 'relief', 'lasso', 'qpfs'};
end
methodFilter = @(met)(any(cellfun(@(m)(isequal(m, met)), methodPrefixes)));
% methodFilter = @(met)(any(cellfun(@(pat)(any(strfind(met, pat)==1)) , ...
%         methodPrefixes) ));

PlotData = []; % a struct
if knngauss
    predictFiles  = dir(sprintf('exp%sexp%d%s%s-vark_*-knngauss.mat', ...
    filesep, expnum, filesep, dataset));    
else
    predictFiles  = dir(sprintf('exp%sexp%d%s%s-vark_*-svcsvr.mat', ...
    filesep, expnum, filesep, dataset));    
end


m = nan;

for fi=1:length(predictFiles)
    fname = predictFiles(fi).name;
    Match = regexp(fname, '(?<data>[\w_\d]+)[-]vark_(?<method>[\w_\d]+)', 'names');
    method = Match.method;
    if methodFilter(method)
        resultPath = sprintf('exp/exp%d/%s', expnum, fname);
        load(resultPath);
        if ~isempty(AvgErr)
            m = size(FMat,2);
            X = 1:m;
            X(isnan(AvgErr)) = [];
            ind = length(PlotData)+1;
            PlotData(ind).X = X;
            PlotData(ind).Y = AvgErr(~isnan(AvgErr));
            PlotData(ind).Method = method;
        end
        
    end
    
end

PlotData = sortPlotData(PlotData);
% Plot

hold on

for mi=1:length(PlotData)
    PData = PlotData(mi);
    %         [linestyles{mi}, MarkerEdgeColors(mi), Markers(mi)], ...
    Style = methodPlotStyle2( PData.Method);
    plot(PData.X, PData.Y, Style{:})
    
end

set(gca, 'FontSize', fontsize);
if ~isnan(m)
    
    set(gca, 'XLim', [1 m]);
end
% Translate labels so that they are the same with the names used in the
% paper.
TranLabels = cellfun(@(m)(labelmap(m)), {PlotData.Method}, 'UniformOutput', false);
legend(TranLabels, 'Interpreter', 'tex', 'FontSize', fontsize-4)
xlabel('Number of features');

load(dataset);
isclassi = isclassification(X,Y);

% HARD-CODED!
n = min(size(X,2), 400);
% determine task
if isclassi
    C = length(unique(Y));
    task = sprintf('%d classes', C);
else
    task = 'regression';
end

if knngauss
    % KNN/ Gaussian regression
    if isclassi
        method = 'KNN';
    else
        method = 'kernel regression';
    end
else
    % SVC/SVR
    if isclassi
        method = 'SVC';
    else
        method = 'SVR';
    end
end
ylabel(['Averaged test error of ', method]);
title(sprintf('%s (m=%d, n=%d, task=%s)', dataset, m, n, task))
hold off
grid on


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function Asorted=sortPlotData(PlotData)
%
% Sort by methods
%
    A = PlotData;
    
    Afields = fieldnames(A);
    Acell = struct2cell(A);
    sz = size(Acell); 

    % Convert to a matrix
    Acell = reshape(Acell, sz(1), []);      % Px(MxN)

    % Make each field a column
    Acell = Acell';                         % (MxN)xP

    
    MO = methodOrder();
    Orders = cellfun(@(me)(MO(me)), Acell(:,3));
    % Sort  (X,Y,Method)
    Acell = sortrows([Acell, num2cell(Orders)], 4);
    Acell = Acell(:, 1:3);
    
    % Put back into original cell array format
    Acell = reshape(Acell', sz);

    % Convert to Struct
    Asorted = cell2struct(Acell, Afields, 1);

end

