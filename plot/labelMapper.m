function labelmap= labelMapper( )
%
% Return a map mapping from method name used in the code to method name
% used in the paper.
%
    methods_code = {'balsmi', 'bahsic', 'folsmi', 'fohsic', 'rlsmi', 'rhsic'...
        'pc', 'pglsmi', 'pghsic', 'mrmr', 'mrmrq', 'relief', 'lasso', ...
        'qpfs'};
    methods_paper = {'B-LSMI', 'B-HSIC', 'F-LSMI', 'F-HSIC', 'R-LSMI', 'R-HSIC',...
        'PC', 'L_1-LSMI', 'L_1-HSIC', 'mRMR', 'mRMRq', 'Relief', 'Lasso', ...
        'QPFS'
        };
    labelmap = containers.Map(methods_code, methods_paper);


end

