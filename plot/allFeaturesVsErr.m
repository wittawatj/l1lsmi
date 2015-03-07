function  allFeaturesVsErr(expnum, datasetPrefixes, methodPrefixes, knngauss)
%
% Plot number of features vs. err on all datasets.
%

rows = 1;
cols = 1;

if nargin < 4
    knngauss=false;
end
if nargin < 3
    % filter: begin with one of ...
%     methodPrefixes = {'balsmi', 'bahsic', 'folsmi','fohsic', 'rlsmi', 'rhsic', 'pc', 'd', 'pg'};
%    methodPrefixes = {'ba', 'fo','r', 'pc', 'd', 'pg'};
    methodPrefixes = {'ba', 'fo', 'pc', 'pg', 'relief','mrmr', 'lasso', 'qpfs'};
end

if nargin < 2
    datasetPrefixes = [num2cell(0:9), num2cell([char('a'+ (0:25)), char('A'+ (0:25))])];
end

datasetFilter = @(met)(any(cellfun(@(pat)(any(strfind(met, pat)==1)) , ...
        datasetPrefixes) ));

Dats = getVarkDatasets(expnum);
j = 1;
di = 1;
for i=1:length(Dats)
    dataset = Dats{i};
    if datasetFilter(dataset)
        if mod(di-1, rows*cols) == 0
            figure
            j = 1;
        end

        subplot(rows, cols, j);

        try
            plotFeaturesVsErr( expnum, dataset, methodPrefixes, knngauss)
            j = j+1;
            di = di + 1;
        catch E
            display(getReport(E));
        end
    end    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function Dats=getVarkDatasets(expnum)

    Files  = dir(sprintf('exp%sexp%d%s*-svcsvr.mat', filesep, expnum, filesep));
    Dats= cell(1, length(Files));
    for i=1:length(Files)
        
        fname = Files(i).name;
        Match = regexp(fname, '(?<data>[\w_\d]+)[-].*', 'names');
        Dats{i} = Match.data;
        
    end
    Dats = unique(Dats);
    
end
