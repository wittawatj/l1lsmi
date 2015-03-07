function M = methodColor( )
%
%
    methods_code = {'pc','fohsic', 'folsmi', 'bahsic','balsmi', ...
         'pghsic', 'pglsmi', 'mrmr', 'relief', 'qpfs', 'lasso'};
    
    colors={
        [210, 105, 30]/255.0, ...%pc
        [1 1 0],... %fohsic
        [0 1 1] ,...%folsmi
        [0 0 1],... % bahsic
        [0 1 0],... % balsmi
        [1,0,1], ...%pghsic
        [1,0,0], ... %pglsmi
        [34, 139, 34]/255.0,... %mrmr
        [0,0,0], ... %relief
        [0.1, 0.2, 0.9] , ...%qpfs
        [52, 162, 154]/255.0 % lasso
    };
    M = containers.Map(methods_code, colors);
        
     
end


%         [70, 130, 180]/255.0,... %fohsic
%         [140, 58, 58]/255.0 ,...%folsmi
%         [12, 212, 11]/255.0,... % bahsic
%         [10, 139, 69]/255.0,... % balsmi
%    