function W2= mlsmi_dis( X, Y, options)
%
% Minimize LSMI. Features which minize LSMI the most are removed.
% The complement is selected.
%
% Algorithm:
% - Initialize W to (1,1,...,1)^T
% - While W not converged:
%   - Solve for Alpha (Alpha must be non-negative)
%   - Solve for W
%

if nargin < 3
    options = [];
end

[m n ] = size(X);
% seed = seed of randomness
seed =  myProcessOptions(options,   'seed', 1 );  

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


% radius = l1 ball's radius
radius = myProcessOptions(options, 'radius', 1);

% fold = number of folds to do in cross validation 
fold = myProcessOptions(options, 'fold', 5);

% degree = degree of the polynomial. Must be an even number
degree = myProcessOptions(options, 'degree', 2);
if mod(degree,2) ~= 0
    error('degree must be even');
end

% lsmilambda_list = list of candidates of LSMI's lambda
lsmilambda_list = myProcessOptions(options, ...
    'lsmilambda_list', logspace(-4, 1, 6));


% b = number of basis functions
b = myProcessOptions(options, 'b', min(100, n) );
optTol = myProcessOptions(options, 'optTol', 1e-7);
progTol = myProcessOptions(options, 'progTol', 1e-9);
maxIter = myProcessOptions(options, 'maxIter', 200);

rand_index = randperm(n);
Xc = X(:, rand_index(1:b));
Yc = Y(:, rand_index(1:b));
    
% Gather all options into options struct
options.radius = radius;
options.fold = fold;
options.lsmilambda_list = lsmilambda_list;
options.seed = seed;
options.b = b;
options.optTol = optTol;
options.progTol = progTol;
options.maxIter = maxIter;

% Begin MLSMI
W2 = 1+2*ones(m,1);
prevW2 = inf(m,1);

Ky = kerDelta(Yc, Y);
KyKy = Ky*Ky';
while norm(W2 - prevW2) > 1e-5
    prevW2 = W2;
    W = sqrt(W2);

    % Begin solving for Alpha
    Z = bsxfun(@times, W, X);    
    Zc = bsxfun(@times, W, Xc);    
    KzPre = 1+kerDot(Zc, Z);
    Kz = KzPre.^degree;

    CVErr = zeros(length(lsmilambda_list), 1);

    I = strapart(Y, fold, seed);    

    % Pre-calculate H, h
    HTrs = cell(1,fold);
    hTrs = cell(1,fold);
    HTes = cell(1,fold);
    hTes = cell(1,fold);

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

%             afunProj = @(a)(max(a,0));
%             afunObj = @(a)(afuncObj(a, HTr, hTr, lsmilambda));            
%             AlphaTr = minConf_SPG(afunObj, ones(b,1), afunProj, struct('verbose',0));
%             AlphaTr=quadprog2((HTr + lsmilambda * eye(b)), -hTr, -eye(b), zeros(b,1));
            
            AlphaTr = (HTr + lsmilambda * eye(b) ) \ hTr;
            Errs(fold_i) = 0.5 * AlphaTr'* HTe * AlphaTr - hTe' * AlphaTr;
        end
        CVErr(lsmilambda_i) = mean(Errs);
    end %lsmilambda

    clear lsmilambda
    
    % Determine the best parameters
    [minerr, i] = min(CVErr(:));
    [bli] = ind2sub(size(CVErr), i);
    best_lsmilambda = lsmilambda_list(bli);

    fprintf('CV: lamb=%.2g\n', best_lsmilambda);

    h = calSmallh(Ky, Kz);
    H = calBigH(Ky, Kz);

%     afunProj = @(a)(max(a,0));
%     afunObj = @(a)(afuncObj(a, H, h, best_lsmilambda));            
%     Alpha = minConf_SPG(afunObj, ones(b,1), afunProj, struct('verbose',0));
    
    Alpha = (H + eye(b)*best_lsmilambda) \ h;

    % Explicit constraint for non-negativity should be imposed.
    % But, Do the hacking for now.
%     Alpha = max(Alpha, 0);

    % Begin solving for W    
    options.corrections = 20;
    funProj = @(w2)(projectPositiveL1(w2, radius));
    nzInd = Alpha~=0;
    funObj = @(w2)(funcObj(w2, X, Xc(:,nzInd), Alpha(nzInd),...
        Ky(nzInd,:), KyKy(nzInd, nzInd), KzPre(nzInd,:), Kz(nzInd,:), ...
        degree, h(nzInd), best_lsmilambda));
    W2 = minConf_PQN(funObj, W2, funProj, options);
    
    norm(prevW2-W2)

end
% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function lsmi = afobj(Alpha, H, h, lamb)
    lsmi = 0.5*Alpha'*H*Alpha - h'*Alpha + 0.5*lamb*(Alpha'*Alpha);
end

function g = agobj(Alpha, H, h, lamb)
    b = length(h);
    g = (H+lamb*eye(b))*Alpha - h;
end

function [f,g] = afuncObj(Alpha, H, h, lamb)
    f = afobj(Alpha, H, h, lamb);
    if nargout > 1
        g = agobj(Alpha, H, h, lamb);
    end
end

function [f, g] = funcObj(W2, X, Xc, Alpha, Ky, KyKy, KzPre, Kz, degree,...
    h, lsmilambda)
    f = fobj(Alpha, h);
    if nargout > 1
        g = gobj(W2, X, Xc, Alpha, Ky, KyKy, KzPre, Kz, degree, lsmilambda);
    end
end

function lsmi = fobj(Alpha, h)
    lsmi = 0.5*h'*Alpha - 0.5;
end

function lsmi = lsmifunc(W,X,Xc, Ky, degree, lsmilambda)
    b = size(Xc,2);
    Z = bsxfun(@times, W, X);    
    Zc = bsxfun(@times, W, Xc);  
    Kz = kerInHoPoly(Zc, Z, degree);
    h = calSmallh(Ky, Kz);
    H = calBigH(Ky, Kz);
    Alpha = (H + eye(b)*lsmilambda) \ h;
%     afunProj = @(a)(max(a,0));
%     afunObj = @(a)(afuncObj(a, H, h, lsmilambda));            
%     Alpha = minConf_SPG(afunObj, ones(b,1), afunProj, struct('verbose',0));
    
    lsmi = 0.5*h'*Alpha - 0.5;
end

function DF = gobj(W2, X, Xc, Alpha, Ky, KyKy, KzPre, Kz, degree, lsmilambda)
    [m n] = size(X);
    b = size(Ky, 1);
    W = sqrt(W2);
    
    Kzd1 = KzPre.^(degree-1); % b x n
    KyKzd1 = Ky.*Kzd1;
    DF = zeros(m,1);
    for k=find( W(:)' > 1e-10) 
        % If wk <= 1e-10, treat it as 0, and its derivative is also 0.
%         wk = W(k);
        
        % Dh/dwk
        Dah = (degree/n)*(Alpha'.*Xc(k,:))*KyKzd1*X(k,:)';
        
        % DH/dwk
        A = repmat(Kzd1, b, 1); % bb x n
        B = Kz(repmat(1:b, b, 1), :); % bb x n
        C = (A.*B)*X(k,:)'; % bb x 1
        clear A B
        C = reshape(C, b, b); % b x b
        D = bsxfun(@times, C, Xc(k,:)'); % b x b
        DaH = (degree/n^2)*Alpha'*((D+D').*KyKy)*Alpha;
        
        DF(k) = Dah - 0.5*DaH;
    end
    
    % Use finite difference to check the calculation of DF
    % It seems to be correct. Nov 7, 2011
    
%     epsi = 1e-6;
%     eDF = zeros(m,1);
%     lsmif = @(w)lsmifunc(w, X, Xc, Ky, degree, lsmilambda);
%     lw = lsmif(W);
%     for k=find( W(:)' > 1e-10) 
%         E = zeros(m,1);
%         E(k) = epsi;
%         Wk = W + E;
%         lsmi_k = lsmif(Wk);
%         eDF(k) = (lsmi_k - lw)/epsi;
%     end
%     display(sprintf('|eDF - DF| = %.3g',norm(eDF-DF)));

end

function h = calSmallh(Phiy, Phiz)
    h = mean(Phiy .* Phiz , 2) ;
end

function H = calBigH(Phiy, Phiz)
    n = size(Phiz, 2);
    H = (Phiy * Phiy') .* (Phiz * Phiz') ./ (n^2);
end

