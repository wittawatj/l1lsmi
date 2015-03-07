function VK = vark_balsmi(X, Y, options )
%
% vark function returns a VK struct.
%
options.k = 1;

t0 = cputime;
tic;

[ BestRecords] = balsmi( X, Y, options );

SB = sortrows([sum(BestRecords(:, 2:end),2), BestRecords], [1]);
SB = SB(:, 2:end);
Score = SB(:, 1);
FMat = logical(SB(:, 2:end));

timetictoc = toc;
timecpu = cputime - t0;

VK.timetictoc = timetictoc;
VK.timecpu = timecpu;
VK.Score = Score;
VK.FMat = FMat;

% Calculate the redundancy rate of the selected features
SumK = sum(FMat,2);
if max(SumK) > 6000
    return;
end

AbsRedunRate = nan(size(FMat,1), 1);
RedunRate = nan(size(FMat,1), 1);

Rho = corrcoef(X'); % full correlation matrix
for i=1:size(FMat,1)
    F = logical(FMat(i,:));
    selected = sum(F);
    if selected <= 1
        RedunRate(i) =  0;
        AbsRedunRate(i) = 0;
    else
        SubRho = Rho(F,F);
        SR_corrs = SubRho(logical(tril(ones(selected),-1)));

        RedunRate(i) =  sum(SR_corrs)/(selected*(selected-1));
        AbsRedunRate(i) =  sum(abs(SR_corrs))/(selected*(selected-1));
    end    
end
VK.AbsRedunRate = AbsRedunRate;
VK.RedunRate = RedunRate;

end