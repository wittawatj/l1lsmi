function  batchAllFeaturesVsErr( )
%
expnum = 6;
knngauss = false;

methods = {'pglsmi', 'pghsic', 'pc', 'mrmr', 'relief', 'lasso', 'qpfs'};
datasets = {'housing', 'cpuact', 'image', 'german', 'isolet', 'segment', ...
    'wine', 'flaresolar', 'spectf', 'satimage', 'vehicle', 'sonar', ...
    'speech', 'senseval2', 'musk1', 'musk2'};

allFeaturesVsErr(expnum, datasets, methods, knngauss);

end

