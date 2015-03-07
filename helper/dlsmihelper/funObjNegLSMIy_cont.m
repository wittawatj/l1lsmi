function [ nlsmi, DF] = funObjNegLSMIy_cont(W, X, Y, const, options, refInfo )
% 
% Function object of DLSMI to be used with Mark Schmidt's optimizer.
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
% Yc = const.Yc;
Kys = const.Kys;
b = size(Xc,2);

% Options
sigmazfactor_list = options.sigmazfactor_list;
sigmayfactor_list = options.sigmayfactor_list;
sigmay_list = const.medy*sigmayfactor_list;
fold = options.fold;
lsmilambda_list = options.lsmilambda_list;
seed = options.seed;

% Calculate negative LSMI
Z = bsxfun(@times, W, X);    
Zc = bsxfun(@times, W, Xc);    
KzPre = kerPreGaussian(Zc, Z);

if doCV(refInfo, options)
   
    % CV to find best lsmilambda, sigmazfactor, sigmayfactor
    
    if isempty(sigmazfactor_list)
        sigmaz_list =  unique( options.sigmaz_list);
    else
        medz = meddistance(Z);
        sigmaz_list =  unique([medz * sigmazfactor_list, options.sigmaz_list]);
    end
    
    CVErr = zeros(length(sigmaz_list),...
        length(lsmilambda_list),...
        length(Kys));

    I = strapartregression(n, fold, seed);

    for szi = 1:length(sigmaz_list) % Gaussian width for Z
        sigmaz = sigmaz_list(szi);
        Kz = exp(KzPre/(2*sigmaz^2));

        % Pre-calculate H, h
        HTrs = cell(length(Kys),fold);
        hTrs = cell(length(Kys),fold);
        HTes = cell(length(Kys),fold);
        hTes = cell(length(Kys),fold);
        for syi = 1:length(Kys)
            Ky = Kys{syi};

            for fold_i = 1:fold
                teI = I(fold_i,:);
                trI = ~teI;                

                KyTr = Ky(:,trI);
                KyTe = Ky(:,teI);
                KzTr = Kz(:,trI);
                KzTe = Kz(:,teI);

                HTrs{syi, fold_i} = calBigH(KyTr, KzTr);
                hTrs{syi, fold_i} = calSmallh(KyTr, KzTr);
                HTes{syi, fold_i} = calBigH(KyTe, KzTe);
                hTes{syi, fold_i} = calSmallh(KyTe, KzTe);
            end
        end

        % CV
        for syi = 1:length(Kys)
            for lsmilambda_i = 1:length(lsmilambda_list) %lsmilambda
                lsmilambda = lsmilambda_list(lsmilambda_i);

                Errs = zeros(fold ,1);
                for fold_i = 1:fold

                    HTr = HTrs{syi, fold_i};
                    HTe = HTes{syi, fold_i};
                    hTr = hTrs{syi, fold_i};
                    hTe = hTes{syi, fold_i};

                    AlphaTr = (HTr + lsmilambda * eye(b) ) \ hTr;
                    Errs(fold_i) = 0.5 * AlphaTr'* HTe * AlphaTr - hTe' * AlphaTr;
                end
                CVErr(szi, lsmilambda_i, syi) = mean(Errs);

            end %lsmilambda
        end % sigmay
    end % sigmaz
    clear Ky Kz lsmilambda

    % Determine the best parameters
    [minerr, i] = min(CVErr(:));
    [bszi, bli, bsyi] = ind2sub(size(CVErr), i);

    best_sigmaz = sigmaz_list(bszi);
    best_lsmilambda = lsmilambda_list(bli);
        
    % Keep chosen parameters in refInfo
    refInfo.obj.best_sigmaz = best_sigmaz;
    refInfo.obj.best_lsmilambda = best_lsmilambda;
    refInfo.obj.bsyi = bsyi; 
    
    fprintf('CV: sigmaz=%.2g, sigmay=%.2g, lamb=%.2g\n', ...
        best_sigmaz, sigmay_list(bsyi), best_lsmilambda);

else % CV should not be performed
    % Use the best parameters from the last CV
    best_sigmaz = refInfo.obj.best_sigmaz;
    best_lsmilambda = refInfo.obj.best_lsmilambda;
    bsyi = refInfo.obj.bsyi;
    
end % end doCV if

BKy = Kys{bsyi};
BKz = exp(KzPre/(2*best_sigmaz^2));

h = calSmallh(BKy, BKz);
H = calBigH(BKy, BKz);

Alpha = (H + eye(b)*best_lsmilambda) \ h;
lsmi = 0.5*h'*Alpha - 0.5;
nlsmi = -lsmi;

if nargout > 1
    % Calculate the derivative
    DF = -deriveIByW(W, X, Xc, Alpha, BKy, BKz, best_sigmaz);
    
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
