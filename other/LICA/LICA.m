function  [W,sigma,lambda,PARAMETERS,Wcand] = LICA(Y,insigma,inlambda,b,INPARAM)
%
% Least squares independent component analysis (LICA)
%
% Usage:
%       [W,sigma,lambda,PARAMETERS,Wcand] = LICA(Y,insigma,inlambda,b,INPARAM)
%
% Input:
%    Y     : dy by n signal matrix 
%
%    insigma: array of candidates of Gaussian width, 
%                          one of them is selected by cross validation.
%    inlambda: array of candidates of the regularization parameter, 
%                          one of them is selected by cross validation.
%    b     : number of Gaussian centers
%    INPARAM: parameters which control the behavior of LICA
%       - Max_Trial: number of trials with different initialization
%                    (default: 3)
%       - Opt_Method: determines which optimization method is used (1 or 2)                 
%                     1: line search
%                     2: gradient descent
%                     (default:2)
%       - Emp_Cost: determines which empirical approximation of the cost
%                   function is used (1 or 2)
%                     1: alpha'*H*alpha - 2*h'*alpha
%                     2: - h'*alpha
%                     (default:2)
%       - Reg_Term: determines which regularization term is used (1 or 2)
%                     1: alpha'*alpha
%                     2: alpha'*K*alpha (K is the Gram matrix)
%                     (default:2)
%      - CV_Freq: controls how frequently cross validation is performed (1 or 2)
%                     1: each iteration
%                     2: 2 times during optimization
%                     (default:2)
%      - FOLDNUM: the number of folds of cross validation. (default:5)
%
% Output:
%     W: d by dx projection matrix
%     sigma,lambda: Gaussian width and regularization parameter which are
%                   finally chosen
%     PARAMETERS: parameters which were used in LDR
%        - Max_Trial, Opt_Method, Reg_Term, Emp_Cost, CV_Freq, FOLDNUM
%     Wcand: solution W for each initialization condition 
%
% (c) Taiji Suzuki, Department of Mathematical Informatics, The University of Tokyo, Japan. 
%     Masashi Sugiyama, Department of Compter Science, Tokyo Institute of Technology, Japan.
%     t-suzuki@mist.i.u-tokyo.ac.jp
%     sugi@cs.titech.ac.jp,


[d n] = size(Y);
MatWhite = Y*Y'/size(Y,2);
MatWhite = inv(sqrtm(MatWhite));
Y = MatWhite*Y;

if nargin < 2  || isempty(insigma)
    insigma = [0.1:0.1:1]; 
end;
if nargin < 3 || isempty(inlambda) 
    inlambda = logspace(-4,0,10); 
end;

if exist('INPARAM','var') && isfield(INPARAM,'Max_Trial') 
    Max_Trial = INPARAM.Max_Trial;
else
    Max_Trial = 3;
end;

if exist('INPARAM','var') && isfield(INPARAM,'Opt_Method') 
    if ismember(INPARAM.Opt_Method ,[1 2])
        Opt_Method = INPARAM.Opt_Method;
    else
        error('Opt_Method should be 1 or 2!!!')
    end;
else
    Opt_Method = 1;
end;

if exist('INPARAM','var') && isfield(INPARAM,'Emp_Cost') 
    if ismember(INPARAM.Emp_Cost,[1 2]) 
        Emp_Cost = INPARAM.Emp_Cost;
    else
        error('Emp_Cost should be 1 or 2!!!')
    end;
else 
    Emp_Cost = 2;
end;

if exist('INPARAM','var') && isfield(INPARAM,'Reg_Term') 
    if ismember(INPARAM.Reg_Term,[1 2]) 
        Reg_Term = INPARAM.Reg_Term;
    else
        error('Reg_Term should be 1 or 2!!!')
    end;
else 
    Reg_Term = 2;
end;

dir_type = 2*(Reg_Term-1) + Emp_Cost;

if exist('INPARAM','var') && isfield(INPARAM,'CV_Freq') 
    if ismember(INPARAM.Emp_Cost,[1 2]) 
        CV_Freq = INPARAM.CV_Freq;
    else
        error('Emp_Cost should be 1 or 2!!!')
    end;
else
    CV_Freq = 2;
end;

if exist('INPARAM','var') && isfield(INPARAM,'FOLDNUM') 
    FOLDNUM = INPARAM.FOLDNUM;    
else 
    FOLDNUM = 5;
end;


if nargin < 4 || isempty(b) 
    b = min(300,n);
else
    b = min(b,n);
end;
ww = randperm(n);
ind = ww(1:b);

cy = Y(:,ind);
for mm = 1:d
    YV{mm} = ones(n,1)*cy(mm,:) - Y(mm,:)'*ones(1,size(cy,2));
end;

sig = insigma(1);
lambda = inlambda(1);

if Opt_Method == 1
    max_iteration = 50;
else
    max_iteration = 200;
end;
epsilon_list= [1 1 1 1 1];

IsHistryInit(1) = -Inf;

figure(100);

for Initial = 1:Max_Trial 
    
    epsilon_count = 0;

    %random initialization of W
    W = wishrnd(eye(d),d);
    [W V D] = svd(W);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    for epsilon=epsilon_list
        b_storeG = 0;

        epsilon_count = epsilon_count + 1;
        b_itrflag = 1;
        for iterate = 1:max_iteration
            fprintf('[%d]\n',iterate);
            X = W*Y;   cx = [X(:,ind)];

            [XV,XV2,XLL] = XV_gen(X,cx);

            %cross validation
            if CV_Freq == 1 || ((iterate == 1 || iterate == 3) && (epsilon_count == 1 || epsilon_count == 3))
                [sig,lambda] = CVinLICA(XLL,XV2,insigma,inlambda,dir_type,ind,FOLDNUM); 
            end;

            if b_storeG
                Gmulti = Gmulti_Store;
                Gmulti2 = Gmulti2_Store;
                Hhat = Hhat_Store;
                GG = GG_Store; 
                hhat = hhat_Store; 
            else
                [GG,Gmulti,Gmulti2,Hhat,hhat] = CalcGLICA(XLL,XV2,sig);
            end;
            
            if ismember(dir_type,[3 4]) 
                RegMat = GG(ind,:) + 1e-8*eye(b,b); 
            else
                RegMat = eye(b,b);
            end;
            alpha = (Hhat + lambda*RegMat)\hhat;
            beta  = (Hhat + lambda*RegMat)\(Hhat*alpha);
            
            Is =  IsCalc(Hhat,hhat,alpha,lambda,dir_type);                         
            
            if  iterate == max_iteration || b_itrflag == 0
                Wlast =  W*MatWhite;
                b_itrflag = 1;
                break;
            end;

            %computation of gradient
            Wdir_h = zeros(d,d);
            Wdir_H = zeros(d,d);
            for l = 1:d

                lind = [1:l-1 l+1:d];
                Win = Gmulti2{lind(1)};
                for lll= lind(2:end)
                    Win = Gmulti2{lll}.*Win;
                end;

                WMAT = XV{l}.*Gmulti{l};
                WRMAT = XV{l}.*GG;
                for ll = 1:d
                    switch dir_type
                        case 1
                            Wdir_h(l,ll) = sum((XV{l}.*(-YV{ll})).*GG,1)*(beta - 2*alpha)/(n*sig^2);

                            Hin = (WMAT.*(- YV{ll}))'*Gmulti{l}/(n*sig^2);
                            Hin = Hin + Hin';

                            Wdir_H(l,ll) = alpha'*(Win.*Hin)*(-beta + 1.5*alpha);
                        case 2
                            Wdir_h(l,ll) = sum((XV{l}.*(-YV{ll})).*GG,1)*(-2*alpha)/(n*sig^2)/2;

                            Hin = (WMAT.*(- YV{ll}))'*Gmulti{l}/(n*sig^2);
                            Hin = Hin + Hin';

                            Wdir_H(l,ll) = alpha'*(Win.*Hin)*(alpha)/2;  
                        case 3
                            WWRMAT = WRMAT.*(-YV{ll});
                            Wdir_h(l,ll) = sum(WWRMAT,1)*(beta - 2*alpha)/(n*sig^2);

                            Hin = (WMAT.*(- YV{ll}))'*Gmulti{l}/(n*sig^2);
                            Hin = Hin + Hin';

                            Wdir_H(l,ll) = alpha'*(Win.*Hin)*(-beta + 1.5*alpha) + ...
                                lambda*alpha'*(WWRMAT(ind,:))*(- beta + alpha)/(sig^2);        
                        case 4
                            WWRMAT = WRMAT.*(-YV{ll});
                            Wdir_h(l,ll) = sum((XV{l}.*(-YV{ll})).*GG,1)*(-2*alpha)/(n*sig^2)/2;

                            Hin = (WMAT.*(- YV{ll}))'*Gmulti{l}/(n*sig^2);
                            Hin = Hin + Hin';

                            Wdir_H(l,ll) = alpha'*(Win.*Hin + (lambda/(n*sig^2))*WWRMAT(ind,:))*(alpha)/2; 
                    end;
                end;
            end;

            Wdir = (Wdir_h + Wdir_H);
            Wdir = (Wdir - W*Wdir'*W);
            
            %Update W by line-search or gradient descent
            if Opt_Method == 1
                %line-search
                Wold = W;
                for epsilon_shrink = [1 0.1 0.01 0.001]
                    epsilon_line = epsilon*epsilon_shrink;
                    Wtmp = W;
                    line_iternum = 20;
                    line_iter_array = [0:1:line_iternum]; 
                    Is_line = ones(1,line_iternum+1)*(-Inf);
                    epsline = zeros(1,line_iternum+1);
                    max_Isline = Is;
                    Is_line(1) = Is;
                    epsline(1) = line_iter_array(1)*epsilon_line;
                    lcount = 1;
                    for line_iter =line_iter_array(2:end);
                        lcount = lcount + 1;
                        epsline(lcount) = line_iter*epsilon_line;
                        W = Wtmp*expm(line_iter*epsilon_line*Wtmp'*Wdir);
                        W = W./sqrt((sum(W.^2,2)*ones(1,size(W,2))));

                        Is_tmp = CompIsLICA(W,Y,sig,lambda,dir_type,ind);                         
                        Is_line(lcount) = Is_tmp;

                        max_Isline = max(Is_line(lcount),max_Isline); 
                        if max_Isline == Is_line(lcount)
                            b_storeG = 1;
                            Gmulti_Store = Gmulti;
                            Gmulti2_Store = Gmulti2;
                            Hhat_Store = Hhat;
                            GG_Store = GG; 
                            hhat_Store = hhat;                        
                        end;
                        if max_Isline > Is && Is_line(lcount) < Is_line(lcount-1)
                            break;
                        end;
                    end;

                    [Is_new maxl] = max(Is_line);
                    stepsize = line_iter_array(maxl);
                    W = Wtmp*expm(stepsize*epsilon_line*Wtmp'*Wdir);
                    W = W./sqrt((sum(W.^2,2)*ones(1,size(W,2))));
                    [U, S, V] = svd(W);
                    W = U*V';
                end;
                if stepsize == 0 || norm(Wold - W) < 0.00005
                    Wlast =  W*MatWhite;
                    b_itrflag = 0;
                end;
            elseif Opt_Method == 2
                %gradient descent
                Wtmpold = W;
                WtmpH = W'*Wdir - Wdir'*W; 
                backwardstep = 0;
                step_mu = 0.1;
                step_beta = 0.3;
                step_alpha = 1;
                Wtmp = W;
                Is_tmp = CompIsLICA(W,Y,sig,lambda,dir_type,ind);
                Is_tmp_old = Is_tmp;

                while 1 %Armijo's rule
                    backwardstep = backwardstep + 1;
                    W = Wtmp*expm(step_alpha*(step_beta)^backwardstep*WtmpH);
                    Is_tmp = CompIsLICA(W,Y,sig,lambda,dir_type,ind);
                    if Is_tmp - Is_tmp_old + step_alpha*(step_beta)^backwardstep*step_mu*trace(WtmpH'*Wtmp'*(-Wdir)) >= 0 || backwardstep > 20
                        break;
                    end;
                end;
                if norm(W - Wtmpold)/norm(Wtmpold) <  0.001 || abs(Is_tmp_old - Is_tmp)/abs(Is_tmp_old) <=  0.000001 || backwardstep > 20
                    Wlast =  W*MatWhite;
                    b_itrflag = 0;
                end;
            end;

        end;
    end;
    
    %estimate the current Is by cross validation
    Is_tmp = CompIsCVLICA(XLL,XV2,sig,lambda,dir_type,ind,FOLDNUM);
        
    if Is_tmp >= max(IsHistryInit)
        Wres = Wlast;
        sigmares = sig;
        lambdares = lambda;   
    end;
    
    IsHistryInit(Initial) = Is_tmp;
    Wcand{Initial} = Wlast;
end;

W = Wres;
sigma = sigmares;
lambda = lambdares;

PARAMETERS = struct('Max_Trial',Max_Trial,...
    'b',b,...
    'Opt_Method',Opt_Method,...
    'Reg_Term',Reg_Term,...
    'Emp_Cost',Emp_Cost,...
    'CV_Freq',CV_Freq,...
    'FOLDNUM',FOLDNUM);

function [XV,XV2,XLL] = XV_gen(X,cx) 
    [d n]= size(X);
    b = size(cx,2);
    
    sqX = sum(X.^2,1);
    Xc = X'*cx;
    sqcx = sum(cx.^2,1);
    XLL = ones(n,1)*sqcx - 2*Xc + sqX'*ones(1,b);

    for l = 1:d
        XV{l} = ones(n,1)*cx(l,:) - X(l,:)'*ones(1,size(cx,2));
        XV2{l} = XV{l}.^2;
    end;


   
function [Is_tmp,alpha] = CompIsLICA(W,Y,sig,lambda,dir_type,ind)

    X = W*Y;cx = X(:,ind);

    [XV,XV2,XLL] = XV_gen(X,cx);

    [GG,Gmulti,Gmulti2,Hhat,hhat] = CalcGLICA(XLL,XV2,sig);

    b = length(ind);
    if dir_type == 3 || dir_type == 4
        RegMat = GG(ind,:) + 1e-8*eye(b,b); 
    else
        RegMat = eye(b,b);                    
    end;
    alpha = (Hhat + lambda*RegMat)\hhat;
    Is_tmp =  IsCalc(Hhat,hhat,alpha,lambda,dir_type); 


