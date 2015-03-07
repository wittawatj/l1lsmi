function S = fs_relief(X, Y, options )
%
% Feature selection with Relief algorithm.
% 

k = options.k;

t0 = cputime;
tic;

if isclassification(X,Y)
    [ranked, weights] = relieff(X',Y',10, 'method','classification');
else
    [ranked, weights] = relieff(X',Y',10, 'method','regression');
end

F = false(1 , size(X, 1) );
F(ranked(1:k) ) = true;

timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.ranked = ranked;
S.weights = weights;


if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

end

