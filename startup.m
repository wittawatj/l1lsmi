% Start up file for dl1lsmi
% This adds necessary paths Matlab's search path
%

fs = filesep();
folders = {'art','plot','helper',...
    'interface','real','other', ...
    ['3rdparty' fs 'L1General'], ...
    ['3rdparty' fs 'libsvm-3.1'], 'demo', ...
    };
addpath(pwd);
fprintf('Add path: %s\n', pwd);
for fi=1:length(folders)
    fol = folders{fi};
    p = [pwd , fs, fol];
    fprintf('Add path: %s\n', p);
    addpath(genpath(p));
end

addpath([pwd fs 'exp'])
expfolders = dir(['exp' fs 'exp*']);
for fi=1:length(expfolders)
    fold = expfolders(fi);
    if fold.isdir
        addpath([pwd fs 'exp' fs fold.name]);
    end
end

base = pwd();
addpath(fullfile(base, '3rdparty'));
addpath(fullfile(base, '3rdparty', 'cvx'));
addpath(fullfile(base, '3rdparty', 'cvx', 'structures'));
addpath(fullfile(base, '3rdparty', 'cvx', 'lib'));
addpath(fullfile(base, '3rdparty', 'cvx', 'functions'));
addpath(fullfile(base, '3rdparty', 'cvx', 'commands'));
addpath(fullfile(base, '3rdparty', 'cvx', 'builtins'));

clear base expfolders fi fol fold folders fs p
