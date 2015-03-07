function FMeasureBar( exp, inDatas, inMethods, renew)
% 
% Bar chart where x-axis is datasets, and y-axis
% is the f-measure. 
% 
if nargin < 4
    renew = false;
end
if nargin < 3  || isempty(inMethods)
    inMethods = {};
end

if nargin < 2  || isempty(inDatas)
    inDatas = {};
end

cacheName = 'fmeasure_cells.mat';
cacheFile = sprintf('exp/exp%d/%s', exp, cacheName);
if renew || ~exist(cacheFile, 'file')
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
labelmap = labelMapper();

IM = ismember(CL, inMethods);
CL = CL(IM);
FM = FM(:, IM);

% Sort methods by methodOrder()
MO = methodOrder();
Order = cellfun(@(k)(MO(k)), CL);
[SO, SI] = sort(Order);
CL = CL(SI);
FM = FM(:, SI);
Methods = cellfun(@(k)(labelmap(k)), CL, 'UniformOutput', false);

% Dataset labels
CDatas = DataInd.keys();
CDInd = DataInd.values();
[V I] = sort(cell2mat(CDInd));
CDL = CDatas(I);
Datasets = cellfun(@(name)(artMap(name)), CDL, 'UniformOutput', false);

%%%%%% Plot %%%%%%
Mean = cellfun(@mean, FM);
Std = cellfun(@std, FM);
figure
hold on

fontsize = 34;
% bar(Mean, 1.5);
handles = barweb(Mean, Std, 1, Datasets, [], ...
    [], [], [], 'xy', Methods, 2, 'plot');

legend(Methods, 'Interpreter','Tex', 'FontSize', fontsize-5);
% legend(CL);

% xlabel('Sample size','FontSize', fontsize);
title(sprintf('F-measure on artificial datasets: n=%d',n), ...
    'FontSize', fontsize);
ylabel('F-measure','FontSize', fontsize);

hold off
grid on
set(gca, 'FontSize', fontsize);

% M = [1 1 0; 0 1 1; 0 1 0; 0.4 0.4 0.4; 1 0 0; 1 0 1; 0 0 1];
% colormap(M(1:length(CL),:));

MC = methodColor();
CM = cellfun(@(m)(MC(m)) , CL, 'UniformOutput' , false);
colormap(vertcat(CM{:}));
% MCMat = [MC('pc'); MC('fohsic'); MC('folsmi'); MC('bahsic'); MC('balsmi');...
%     MC('pghsic'); MC('pglsmi')];
% colormap(MCMat)

% set(gca, 'XTick', 1:length(CDL))
% set(gca, 'XTickLabel', CDL);

% CM = flipdim( hsv(9), 1);
% colormap(CM);
% colormap hsv;

% set(gca, 'YLim', [0 1]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function methodColorMap()
    methods_code = {'pc','fohsic', 'folsmi', 'bahsic','balsmi', ...
         'pghsic', 'pglsmi', 'mrmr', 'relief'};
    
    colors={
        [0, 1, 0.66], ...%pc
        [0, 0.66, 1],... %fohsic
        [1, 0.66,0] ,...%folsmi
        [0, 0, 1],... % bahsic
        [0.66, 1, 0],... % balsmi
        [1,0, 0.66], ...%pghsic
        [1,0,0], ... %pglsmi
        [0, 0.5, 0.1],... %mrmr
        [1,0,1], ... %relief
    };
    M = containers.Map(methods_code, colors);        
end

