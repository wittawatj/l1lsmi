function VK = vark_qpfs(X, Y, o )
%
% Options qpfs_alpha works.

[m n] = size(X);
o.k = 1;

S = fs_qpfs(X, Y, o);
if isempty(S)
    VK=[];
    return;
end
W = S.W;
[SW I] = sort(W, 'descend');
K(I) = 1:m;
T = tril(true(m));

FMat = T(:,K);
Score = [];


VK.timetictoc = S.timetictoc;
VK.timecpu = S.timecpu;

VK.Score = Score;
VK.FMat = FMat;
VK.alpha = S.alpha;
VK.Q = S.Q;
VK.f = S.f;
VK.W = S.W;

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

