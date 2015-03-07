function S = fs_rlsmi( X, Y, options )
%
% Ranking LSMI. Calculate LSMI between Xi and Y.
% Rank features based on the LSMI score.
%

k = options.k;
[m n] = size(X);

sigmaxfactor_list = myProcessOptions(options, 'sigmaxfactor_list', ...
    [1/5, 1/2, 1, 2, 5]);
lsmilambda_list = myProcessOptions(options, 'lsmilambda_list', [1e-4]);
seed =  myProcessOptions(options,   'seed', 1 );  
% b = number of basis functions
b = myProcessOptions(options, 'b', min(100, n) );
deltakernel = myProcessOptions(options, 'deltakernel', isclassification(X,Y));
% fold = number of folds to do in cross validation 
fold = myProcessOptions(options, 'fold', 2);

O.sigmaxfactor_list = sigmaxfactor_list;
O.lambda_list = lsmilambda_list;
O.seed = seed;
O.b = b;
O.deltakernel = deltakernel;
O.fold = fold;

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


t0 = cputime;
tic;

LS = LSMIEach(X,Y, O);
LS(isnan(LS)) = -inf;
[LS , LSMIInd] = sort(LS, 'descend');

F = false(1 , size(X, 1) );
F(LSMIInd(1:k) ) = true;

timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.LSMI = LS;
S.LSMIInd = LSMIInd;


if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);


end


function LS = LSMIEach(X,Y, O)
% Return a score column vector
    
    [m n] = size(X);
    LS = zeros(m, 1 );
    for i = 1:m
        Xi = X(i,:);
        med = meddistance(Xi);
        O.sigma_list = med*O.sigmaxfactor_list;
        lsmi = LSMI(Xi, Y, O);
        LS(i) = lsmi;
    end
    
end
