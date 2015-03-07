function S = fs_mrmr(X, Y, options )
% 
% Feature selection with mRMR
% 

X = double(X);
Y = double(Y);
if ~isclassification(X,Y)
%     error('%s: mRMR supports only discrete Y');
    
    % Discretize Y into 5 states
    Y = sigmadiscretize2(Y, 2);
end

k = options.k;

t0 = cputime;
tic;

%  Discretize X into 5 states
DX = sigmadiscretize2(X,2);
[fea] = mrmr_mid_d( DX', Y', k);

F = false(1 , size(X, 1) );
F(fea) = true;

timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.fea = fea;


if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

end

