function VK = vark_lasso(X, Y, o )
%
%
[m n] = size(X);
o.k = 1;
o.lasso_numlambda = myProcessOptions(o, 'lasso_numlambda', 2*m);

S = fs_lasso( X, Y, o);
if isempty(S)
    VK=[];
    return;
end
B = logical(S.B)'; % .. x m
SB = sum(B,2);
Lambda = S.FitInfo.Lambda';
MSE = S.FitInfo.MSE';

UR = unique(SB);
UR(UR==0) = [];

FMat = false(length(UR), m);
Score = zeros(length(UR),1);
for i=1:length(UR)
    selected = UR(i);
    I = (SB == selected);
    SR = sortrows( [MSE(I), Lambda(I), B(I, :) ], [1 2]);
    FMat(i,:) = logical(SR(1, 3:end));
    Score(i) = -SR(1,1); % score = -mse
end

VK.timetictoc = S.timetictoc;
VK.timecpu = S.timecpu;

VK.Score = Score;
VK.FMat = FMat;
VK.B = B;
VK.Lambda = Lambda;
VK.MSE = MSE;

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

