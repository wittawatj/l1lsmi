% KPM
fprintf('Compiling KPM files...\n');
mex KPM/repmatC.c

% minFunc
fprintf('Compiling minFunc files...\n');
mex minFunc/lbfgsC.c
mex minFunc/mcholC.c

% UGM
fprintf('Compiling UGM files...\n');
mex -IUGM/mex UGM/mex/UGM_makeNodePotentialsC.c
mex -IUGM/mex UGM/mex/UGM_makeEdgePotentialsC.c
mex -IUGM/mex UGM/mex/UGM_Infer_ExactC.c
mex -IUGM/mex UGM/mex/UGM_MRFLoss_subC.c
mex -IUGM/mex UGM/mex/UGM_updateGradientC.c





