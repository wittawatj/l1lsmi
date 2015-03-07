function  allVvsFeatures(expnum, methodPrefixes, restart )
%
% Plot V vs number of features on all datasets.
%

rows = 2;
cols = 2;

if nargin < 3
    restart = 1;
end

if nargin < 2
    % filter: begin with one of ...
    methodPrefixes = {'dlsmi', 'dhsic'};
end

Dats = getAllDatasets(expnum);
j = 1;
for i=1:length(Dats)
    
    if mod(i, rows*cols) == 1
        figure
        j = 1;
    end
    
    subplot(rows, cols, j);
    dataset = Dats{i};
    plotVvsFeatures(expnum, dataset, ...
        methodPrefixes, restart );
    j = j+1;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

