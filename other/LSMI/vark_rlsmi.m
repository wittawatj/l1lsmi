function VK = vark_rlsmi(X, Y, options )
%
%
[m n] = size(X);
S = fs_rlsmi( X, Y, options );
Score = cumsum(S.LSMI);
T = tril(true(m));

InverseInd = zeros(1,m);
InverseInd(S.LSMIInd) = 1:m;
FMat = T(:, InverseInd);

VK.timetictoc = S.timetictoc;
VK.timecpu = S.timecpu;

VK.Score = Score;
VK.FMat = FMat;
VK.LSMI = S.LSMI;
VK.LSMIInd = S.LSMIInd;

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

