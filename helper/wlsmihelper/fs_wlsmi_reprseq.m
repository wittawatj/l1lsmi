function S = fs_wlsmi_reprseq(X, Y, options )
%
% fs function returns a struct.
%

options.wlearner = @wlsmi;
options.vtuner = @vtuner_rseq;

t0 = cputime;
tic;

[VT, VTLogs] = vtuner_rep(X, Y, options);

[m n] = size(X);
F = false(1,m);
F(VT.rankList) = true;

timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.VT = VT;
S.VTLogs = VTLogs;

if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end


end