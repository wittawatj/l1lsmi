function S = fs_pc(X, Y, options )
%
% Compute the Pearson correlation between each feature and Y.
% Select the top k feature having the highest absolute correlation values.
% Can only detect linear dependency.
%
k = options.k;

t0 = cputime;
tic;

if isclassification(X,Y) && length(unique(Y)) > 2 
    % Assume a classification task
    [Corr, CorrInd] = sort( absCorrM(X, Y) ,'descend' );
else % regression or binary classification
    [Corr, CorrInd] = sort( absCorrR(X, Y) ,'descend' );
end
F = false(1 , size(X, 1) );
F(CorrInd(1:k) ) = true;

timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.Corr = Corr;
S.CorrInd = CorrInd;


if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
