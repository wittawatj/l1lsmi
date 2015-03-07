function exp6(data, vark_func, trial)
%
% For vark experiments.
%
maxn = 400;


if ischar(data)
    % data is string. Assume it is the path name for real data.
    load(data);
    [ X, Y] = shuffler(X, Y, maxn, trial); 
else
    error('data must be string (dataset path)');
end

[m n] = size(X);

% Dummy k
o.k = 1;

% Options: L1
o.seed = trial;
o.wranker = @(w)(wranker_thresh(w,1e-8));
o.v_min = 1e-4; % for vtuner_seq 
o.v_max = 1; % for vtuner_rseq
o.fold = 5; 
o.b = min(100,n);
o.initWs = [ones(m,1), 2*rand(m,4)]; % for vtuner_rep
o.lsmilambda_list = logspace(-3,1,5); % 

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
o.ztuner_repeat = 10;
o.z_min = 1e-2;
o.z_max = 1e2;
o.zinitWfunc = @zinitW;

% Options: vark_d
o.bindepthlimit = 12;
if m <= 20
    fsteps = 1;
elseif m <= 30
    fsteps = 2;
else
    fsteps = ceil(m/10.0);
end
   
o.featuresteps = fsteps; % for vark_pg
o.vsteps = min(ceil(1.5*m), 150);
o.zsteps = o.vsteps; % zsteps is used in vark_pg

% Normalize data
X = normdata(X);
if ~isclassification(X,Y)
    Y = normdata(Y);
end

fstr = func2str(vark_func);
if any(strfind(fstr, 'vark_dlsmi')==1)    
    
elseif any(strfind(fstr, 'vark_balsmi')==1) ...
        || any(strfind(fstr, 'vark_folsmi')==1) ...
        || any(strfind(fstr, 'vark_rlsmi')) 
    
    % Options: FOLSMI, BALSMI
    o.sigmaxfactor_list = o.sigmazfactor_list;
    
elseif any(strfind(fstr, 'vark_bahsic')==1) ...
        || any(strfind(fstr, 'vark_fohsic')==1) ...
        || any(strfind(fstr, 'vark_rhsic')==1) 
    
elseif any(strfind(fstr, 'vark_dhsic')==1) 
    
    
elseif any(strfind(fstr, 'vark_pc')==1) 
     
elseif any(strfind(fstr, 'vark_pglsmi')==1) 
    
elseif any(strfind(fstr, 'vark_pghsic')==1) 

elseif any(strfind(fstr, 'vark_mrmr')==1) 

elseif any(strfind(fstr, 'vark_mrmrq')==1) 

elseif any(strfind(fstr, 'vark_relief')==1) 

elseif any(strfind(fstr, 'vark_lasso')==1) 

elseif any(strfind(fstr, 'vark_qpfs')==1) 

else
    error('Options not set for %s', fstr);
    
end

% Just give up when it is too large for sequential search
if any(regexp(fstr, 'vark_(folsmi|fohsic|balsmi|bahsic)')) ...
        && size(X,1) > 200
    exit();
end

try 
    
    datapath = data;
    [p, dataname, e] = fileparts(datapath);
    vark_func_str = func2str(vark_func);
    vark_str = regexprep( vark_func_str, 'fs_', '');
    
    % Create a folder     
    fol = sprintf('%s-%s', dataname , vark_str); 
    mkdir(fol);
    dest = sprintf('%s%s%s-%d.mat', fol, filesep(), fol, trial);
    
    % Don't run anything if the result already exists
    ff = dir(dest);
    if ~isempty(ff)
        fprintf('%s exists. Not running feature selection.\n', dest);
        exit();
    end
    
    VK = vark_func(X, Y, o);
    if isempty(VK)
        exit();
    end
    % save variables
    toSave = {'datapath', 'vark_func_str', 'VK', 'trial', ...
        'm', 'n', 'Y', 'o','savetime', 'dataname'};
    
    savetime = datestr(now());
    save(dest, toSave{:});
    
    exit();
catch E
    display(E.getReport);
    % if an error occurs, just exit
    exit();
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end 

