function S = fs_fohsic(X, Y, options )
%
% fs function returns a struct.
%

t0 = cputime;
tic;

[ BestRecords, Records ] = fohsic(X, Y, options);

F = logical( BestRecords(end ,2:end) );
timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.BestRecords = BestRecords;
S.Records = Records;


if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

end