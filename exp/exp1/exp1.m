function exp1(data_gen_func, fs_func, trial)
%
% For artificial data experiment
%

[X,Y,D] = data_gen_func(400, trial);
[m n] = size(X);
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
    o.sigmaxfactor_list = [1/5, 1/2, 1, 2, 5];
    
elseif any(strfind(fstr, 'fs_bahsic')==1) ...
        || any(strfind(fstr, 'fs_fohsic')==1) ...
        || any(strfind(fstr, 'fs_rhsic')==1) 
    
elseif any(strfind(fstr, 'fs_dhsic')==1) 
    
    
elseif any(strfind(fstr, 'fs_pc')==1) 
    
elseif any(strfind(fstr, 'fs_pglsmi')==1) 
    
elseif any(strfind(fstr, 'fs_pghsic')==1) 

elseif any(strfind(fstr, 'fs_mrmr')==1) 

elseif any(strfind(fstr, 'fs_relief')==1) 
   
elseif any(strfind(fstr, 'fs_lasso')==1) 
       
elseif any(strfind(fstr, 'fs_qpfs')==1) 
    
else
    error('Options not set for %s', fstr);
    
end

% Options: L1
o.seed = trial;
o.wranker = @(w)(wranker_thresh(w,1e-8));
% set number of selected features to the number of correct features
o.k = length(D{1}); 
o.v_min = 1e-4; % for vtuner_seq
o.v_max = 1; % for vtuner_rseq
o.fold = 5;
o.b = min(100,n);
o.initWs = [ones(m,1), 2*rand(m,4)]; % for vtuner_rep
o.lsmilambda_list = logspace(-4,1,5); 

% Options: DLSMI
o.sigmazfactor_list = [1/5, 1/2, 1, 2, 5];
o.sigmaz_list = (1/sqrt(2))*[1/5, 1/2, 1, 2, 5];
o.sigmayfactor_list = [1];
o.bootingcvs = 3;
o.cvevery = 5;

% Options: DHSIC
o.bootingmedheu = o.bootingcvs;
o.medheuevery = o.cvevery;

% Options: PGLSMI
o.ztuner_repeat = 20; %%%
o.z_min = 1e-1;
o.zsteps = 20;
o.zbinsteps = 12;

try        

    data_gen_func_str = func2str(data_gen_func);
    fs_func_str = func2str(fs_func);
    
    fsstr = regexprep( fs_func_str, 'fs_', '');
    genstr = regexprep(data_gen_func_str, 'gen_', '');
    
    % Create a folder     
    fol = sprintf('%s-%s', genstr , fsstr); 
    mkdir(fol);
    dest = sprintf('%s%s%s-%d.mat', fol, filesep(), fol, trial);
    ff = dir(dest);
    if ~isempty(ff)
        fprintf('%s exists. Not running feature selection.\n', dest);
        exit(); 
    end

    S = fs_func(X, Y, o);
    savetime = datestr(now());
    [m n] = size(X);
    save(dest, 'data_gen_func_str', 'fs_func_str', 'S', 'trial', 'm', 'n',...
        'Y','D', 'o','savetime');
    
    exit();
catch E
    display(E.getReport);
    % if an error occurs, just exit
    exit();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end 

