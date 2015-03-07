function M = methodOrder( )
%
% Return a map mapping from a method (string) to its order that should be
% used in a plot.
%

    methods_code = {'pc','fohsic', 'folsmi', 'bahsic','balsmi', ...
         'pghsic', 'pglsmi', 'mrmr','qpfs', 'lasso', 'relief','rhsic', 'rlsmi'};
    
    methods_order = num2cell(1:length(methods_code));
    M = containers.Map(methods_code, methods_order);

end

