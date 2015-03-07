function VK = vark_folsmi(X, Y, options )
%
% fs function returns a struct.
%
[m n] = size(X);
options.k = m;

t0 = cputime;
tic;

[ BestRecords] = folsmi(X, Y, options);
Score = BestRecords(:,1);
FMat = logical(BestRecords(:, 2:end));

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