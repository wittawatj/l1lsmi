function [ nlsmi, DF] = fobjNemiLSMI_cont(W, X, Y, const, options, refInfo)
% 
% Function object of DLSMI to be used with Mark Schmidt's optimizer and 
% plaingradient.m.
% const = structure containing constants
% W = an m-dimensional column vector
%

[m n] = size(X);

if all(W==0) 
    nlsmi = inf;
    DF = zeros(m,1);
    return;
end
    
% Initialize constants
Xc = const.Xc;
Yc = const.Yc;
b = size(Xc,2);

% Options
sigmazfactor_list = options.sigmazfactor_list;
fold = options.fold;
lsmilambda_list = options.lsmilambda_list;
seed = options.seed;

% Calculate negative LSMI
Z = bsxfun(@times, W, X);    
Zc = bsxfun(@times, W, Xc);    
KzPre = kerPreGaussian(Zc, Z);
KyPre = kerPreGaussian(Yc, Y);

if doCV(refInfo, options)

    % CV to find best lsmilambda, sigmazfactor, sigmayfactor    
    if isempty(sigmazfactor_list)
        sigmaz_list =  unique( options.sigmaz_list);
    else
        medz = meddistance(Z);
        display(sprintf('medz=%.2g', medz));
        sigmaz_list =  unique([medz * sigmazfactor_list, options.sigmaz_list]);
    end

    CVErr = zeros(length(sigmaz_list), length(lsmilambda_list));
    I = strapartregression(n, fold, seed);

    for szi = 1:length(sigmaz_list) % Gaussian width for Z
        sigmaz = sigmaz_list(szi);
        Kz = exp(KzPre/(2*sigmaz^2));
        Ky = exp(KyPre/(2*sigmaz^2));

        % Pre-calculate H, h
        HTrs = cell(fold, 1);
        hTrs = cell(fold, 1);
        HTes = cell(fold, 1);
        hTes = cell(fold, 1);

        for fold_i = 1:fold
            teI = I(fold_i,:);
            trI = ~teI;                

            KyTr = Ky(:,trI);
            KyTe = Ky(:,teI);
            KzTr = Kz(:,trI);
            KzTe = Kz(:,teI);

            HTrs{fold_i} = calBigH(KyTr, KzTr);
            hTrs{fold_i} = calSmallh(KyTr, KzTr);
            HTes{fold_i} = calBigH(KyTe, KzTe);
            hTes{fold_i} = calSmallh(KyTe, KzTe);
        end

        % CV        
        for lsmilambda_i = 1:length(lsmilambda_list) %lsmilambda
            lsmilambda = lsmilambda_list(lsmilambda_i);

            Errs = zeros(fold ,1);
            for fold_i = 1:fold

                HTr = HTrs{fold_i};
                HTe = HTes{fold_i};
                hTr = hTrs{fold_i};
                hTe = hTes{fold_i};

                AlphaTr = (HTr + lsmilambda * eye(b) ) \ hTr;
                Errs(fold_i) = 0.5 * AlphaTr'* HTe * AlphaTr - hTe' * AlphaTr;
            end
            CVErr(szi, lsmilambda_i) = mean(Errs);

        end %lsmilambda
    end % sigmaz
    clear Ky Kz lsmilambda

    % Determine the best parameters
    [minerr, i] = min(CVErr(:));
    [bszi, bli] = ind2sub(size(CVErr), i);

    best_sigmaz = sigmaz_list(bszi);
    best_lsmilambda = lsmilambda_list(bli);

    % Keep chosen parameters in refInfo
    refInfo.obj.best_sigmaz = best_sigmaz;
    refInfo.obj.best_lsmilambda = best_lsmilambda;
    
    fprintf('CV: err=%.2g, sigmaz=%.2g, lamb=%.2g\n', minerr, best_sigmaz, best_lsmilambda);
else % CV should not be performed
    % Use the best parameters from the last CV
    best_sigmaz = refInfo.obj.best_sigmaz;
    best_lsmilambda = refInfo.obj.best_lsmilambda;
    
end % end doCV if

BKy = exp(KyPre/(2*best_sigmaz^2));
BKz = exp(KzPre/(2*best_sigmaz^2));

h = calSmallh(BKy, BKz);
H = calBigH(BKy, BKz);

Alpha = (H + eye(b)*best_lsmilambda) \ h;
lsmi = 0.5*h'*Alpha - 0.5;
nlsmi = -lsmi;

% Try to find the approximate of \int \int g(x,y) dx dy
% sum1 = mean(Alpha'*(repmat(BKz, 1, n).*BKy(:, repmat(1:n, n, 1))))

if nargout > 1
    % Calculate the derivative
    DF = -deriveIByW(W, X, Xc, Alpha, BKy, BKz, best_sigmaz) ;
    DF
    W
    % Use finite difference to check the calculation of DF
%     epsi = 1e-6;
%     eDF = zeros(m,1);
%     lsmif = @(w)lsmifunc(w,X,Xc, Ky, best_sigmaz, best_lsmilambda);
%     lw = lsmif(W);
%     for k=1:m
%         E = zeros(m,1);
%         E(k) = epsi;
%         Wk = W + E;
%         lsmi_k = lsmif(Wk);
%         eDF(k) = (lsmi_k - lw)/epsi;
%     end
%     display(sprintf('|eDF - DF| = %.3g',norm(eDF-DF)));
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
end

function lsmi = lsmifunc(W,X,Xc, Ky, sigmaz, lsmilambda)
    b = size(Xc,2);
    Z = bsxfun(@times, W, X);    
    Zc = bsxfun(@times, W, Xc);  
    Kz = kerGaussian(Zc, Z, sigmaz);
    h = calSmallh(Ky, Kz);
    H = calBigH(Ky, Kz);
    Alpha = (H + eye(b)*lsmilambda) \ h;
    lsmi = 0.5*h'*Alpha - 0.5;
end

function h = calSmallh(Phiy, Phiz)
% (Correct: Nov 11, 2010)
    h = mean(Phiy .* Phiz , 2) ;
end

function H = calBigH(Phiy, Phiz)
% (Correct: Nov 11, 2010)
    n = size(Phiz, 2);
    H = (Phiy * Phiy') .* (Phiz * Phiz') ./ (n^2);
end
