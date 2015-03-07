function batchFMeasureBar( )

expn = 1;
renew = false;
inDatas = {'andor', 'sca3', 'xor'};


 allMethods = {'pc', 'fohsic', 'folsmi', 'bahsic', 'balsmi', 'pghsic' ,...
     'pglsmi', 'mrmr', 'qpfs', 'lasso', 'relief'};
inMethods1 = {'pc', 'fohsic', 'folsmi', 'bahsic', 'balsmi', 'pghsic' ,...
    'pglsmi'};

% FMeasureBar( expn, inDatas, inMethods1, renew);

inMethods2 = {'pglsmi', 'mrmr', 'qpfs', 'lasso', 'relief'};

% FMeasureBar( expn, inDatas, inMethods2, renew);


FMeasureBar( expn, inDatas, allMethods, renew);

end

