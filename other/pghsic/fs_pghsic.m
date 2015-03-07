function S = fs_pghsic(X, Y, options )
%
% fs function returns a struct.
%

options.wlearner = @pghsic;
options.ztuner = @ztuner_seq_radius;


t0 = cputime;
tic;

[ZT, ZTLogs] = ztuner_rep(X, Y, options);

[m n] = size(X);
F = false(1,m);
% If more than k features are selected, cut to k.
k = options.k;
cut = min(k, length(ZT.rankList));
F(ZT.rankList(1:cut)) = true;

timetictoc = toc;
timecpu = cputime - t0;

% set the time to be the average over all restarts
ztuner_repeat = myProcessOptions(options, 'ztuner_repeat', 5);

S.timetictoc = timetictoc/ztuner_repeat; 
S.timecpu = timecpu/ztuner_repeat;
S.F = F;
S.ZT = ZT;
S.ZTLogs = ZTLogs;

if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

end