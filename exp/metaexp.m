
% Normalize data
X = normdata(X);

fstr = func2str(fs_func);
if any(strfind(fstr, 'fs_wlsmi')==1) % begin with ..
    % Options: WLSMI    
    o.sigmayfactor_list = [1];    
elseif any(strfind(fstr, 'fs_dlsmi')==1)    
    
elseif any(strfind(fstr, 'fs_balsmi')==1) ...
        || any(strfind(fstr, 'fs_folsmi')==1) ...
        || any(strfind(fstr, 'fs_rlsmi')) 
    
    % Options: FOLSMI, BALSMI
    o.sigmaxfactor_list = o.sigmazfactor_list;
    
elseif any(strfind(fstr, 'fs_bahsic')==1) ...
        || any(strfind(fstr, 'fs_fohsic')==1) ...
        || any(strfind(fstr, 'fs_rhsic')==1) 
    
elseif any(strfind(fstr, 'fs_dhsic')==1) 
    
    
elseif any(strfind(fstr, 'fs_pc')==1) 
     
elseif any(strfind(fstr, 'fs_pglsmi')==1) 
    
elseif any(strfind(fstr, 'fs_pghsic')==1) 

elseif any(strfind(fstr, 'fs_mrmr')==1) 

elseif any(strfind(fstr, 'fs_mrmrq')==1) 

elseif any(strfind(fstr, 'fs_relief')==1) 

elseif any(strfind(fstr, 'fs_lasso')==1) 
    
elseif any(strfind(fstr, 'fs_qpfs')==1) 

else
    error('Options not set for %s', fstr);
    
end

% Just give up when it is too large for sequential search
if any(regexp(fstr, 'fs_folsmi|fs_fohsic|fs_balsmi|fs_bahsic')) ...
        && size(X,1) > 200
    exit();
end

try 
    
    datapath = data;
    [p, dataname, e] = fileparts(datapath);
    fs_func_str = func2str(fs_func);
    fsstr = regexprep( fs_func_str, 'fs_', '');
    
    % Create a folder     
    fol = sprintf('%s-%s', dataname , fsstr); 
    mkdir(fol);
    dest = sprintf('%s%s%s-%d.mat', fol, filesep(), fol, trial);
    
    % Don't run anything if the result already exists
    ff = dir(dest);
    if ~isempty(ff)
        fprintf('%s exists. Not running feature selection.\n', dest);
        return;
    end
    
    S = fs_func(X, Y, o);
    if isempty(S)
        exit();
    end
    F = S.F; % feature indicator vector (binary vector)
    
    % Test with a classifier/regressor
    % learner's options
    learneropts.gaussreg_sigmafactor_list = [1/5, 1/2, 1, 2, 5];
    learneropts.gaussreg_lambda_list = 10.^(-3:4);
    learneropts.knn_K = [1 2 5 7 10 20 30];
    learneropts.fold = o.fold;
    learneropts.seed = o.seed;
    learneropts.libsvm_isclassi = isclassification(X,Y);
    learneropts.libsvm_C = 10.^(-3:4);
    learneropts.libsvm_sigmaxfactor_list = [1/5, 1/2, 1, 2, 5];
    
    o = handles2str(o); % reduce space
    % save variables
    toSave = {'datapath', 'fs_func_str', 'S', 'trial', ...
        'm','n', 'Y', 'o','savetime', 'dataname', 'learneropts'};
    
    FX = X(F,:); % data already normalized
    if isclassification(X,Y)
        % test with SVC , kNN
        [ bestk, knn_err, CVErr] = knn_cv( FX, Y, learneropts);
        Knn.bestk = bestk;
        Knn.knn_err = knn_err;
        Knn.CVErr = CVErr;
        
        [bestsigmafactor, bestc, libsvm_err, CVErr] = libsvm_cv( FX, Y, learneropts);
        Svc.bestsigmafactor = bestsigmafactor;
        Svc.bestc = bestc;
        Svc.libsvm_err = libsvm_err;
        Svc.CVErr = CVErr;
        
        toSave{end+1} = 'Knn';
        toSave{end+1} = 'Svc';
    else
        % test with SVR, Gaussian regression
        [bestsigmafactor, bestc, libsvm_err, CVErr] = libsvm_cv( FX, Y, learneropts);
        Svr.bestsigmafactor = bestsigmafactor;
        Svr.bestc = bestc;
        Svr.libsvm_err = libsvm_err;
        Svr.CVErr = CVErr;
        
        [bestsigmafactor, bestlambda, gaussreg_err, CVErr] = gaussRegression_cv( FX, Y, learneropts);
        Gaussreg.bestsigmafactor = bestsigmafactor;
        Gaussreg.bestlambda = bestlambda;
        Gaussreg.gaussreg_err = gaussreg_err;
        Gaussreg.CVErr = CVErr;
        
        toSave{end+1} = 'Svr';
        toSave{end+1} = 'Gaussreg';
    end
    
    savetime = datestr(now());
    save(dest, toSave{:});
    
    
catch E
    display(E.getReport);
    % if an error occurs, just exit
    exit();
end

