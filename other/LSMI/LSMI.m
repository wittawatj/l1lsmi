)function [MIh,score_cv, alphah]=LSMI(x,y,options)
%
% Least-Squares Mutual Information (with likelihood cross validation)
%
% Estimating a squared-loss variant of mutual information 
%    \frac{1}{2}\int\int (\frac{p_{xy}(x,y)}{p_x(x)p_y(y)}-1)^2 p_x(x)p_y(y) dx dy
% from input-output samples
%    { (x_i,y_i) | x_i\in R^{dx}, y_i\in R^{dy} }_{i=1}^n 
% drawn independently from a joint density p_{xy}(x,y).
% p_x(x) and p_y(y) are marginal densities of x and y, respectively.
% 
% Usage:
%       [MIh,score_cv,
%       alphah]=LSMI(x,y,deltakernel,sigma_list,lambda_list,b,fold,labelvec
%       torized)
%
% Input:
%    x          : dx by n input sample matrix
%    y          : dy by n output sample matrix
%    deltakernel: if deltakernel=1, delta kernel is used for y; 
%                 otherwise (or empty) Gaussian kernel is used.
%    sigma_list : (candidates of) Gaussian width
%                 If sigma_list is a vector, one of them is selected by cross validation.
%                 If sigma_list is a scalar, this value is used without cross validation
%                 If sigma_list is empty/undefined, Gaussian width is chosen from
%                 some default canditate list by cross validation
%    lambda_list: (OPTIONAL) regularization parameter
%                 If lambda_list is a vector, one of them is selected by cross validation.
%                 If lambda_list is a scalar, this value is used without cross validation
%                 If lambda_list is empty, Gaussian width is chosen from
%                 some default canditate list by cross validation
%    b          : number of Gaussian centers (if empty, b=200 is used);
%
% Output:
%    MIh        : estimated mutual information between x and y
%    score_cv   : cross validation score
%
% (c) Taiji Suzuki, Department of Mathematical Informatics, The University of Tokyo, Japan. 
%     Masashi Sugiyama, Department of Compter Science, Tokyo Institute of Technology, Japan.
%     s-taiji@stat.t.u-tokyo.ac.jp
%     sugi@cs.titech.ac.jp,
%
%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Nuke
% April 8, 2011:
%  - Change y_type to deltakernel
% April 15, 2011:
%  - options struct as the argument. No more long-listed arguments.

if nargin<2
  error('number of input arguments is not enough!!!')
end

if nargin < 3
    options = [];
end

n =size(x,2);
ny=size(y,2);
if n ~= ny
  error('x and y must have the same number of samples!!!')
end;

% If true, then Delta kernel is used on Y (for classification problems).
deltakernel = myProcessOptions(options, 'deltakernel' , isclassification(x,y) ); 
sigma_list = myProcessOptions(options, 'sigma_list', logspace(-2,2,9));
lambda_list = myProcessOptions(options, 'lambda_list', logspace(-3,1,9));
b = myProcessOptions(options, 'b' , 200);
fold = myProcessOptions(options, 'fold', 5);

b=min(n,b);

if size(y,1) > 1
    deltakernel = 0;
    
end

options.deltakernel = deltakernel;
options.sigma_list = sigma_list;
options.lambda_list = lambda_list;
options.b = b;
options.fold = fold;


%Gaussian centers are randomly chosen from samples
rand_index=randperm(n);
u=x(:,rand_index(1:b));
v=y(:,rand_index(1:b));

%Phi_tmp =GaussBasis_sub([x;y],[u;v])';
Phix_tmp=GaussBasis_sub(x,u)'; % Phix_tmp is b x n

if deltakernel
    Phiy_sigma=DeltaBasis(y,v);% Phiy_sigma is b x n
    Phiy = Phiy_sigma;
else
    Phiy_tmp=GaussBasis_sub(y,v)';
end

if length(sigma_list)==1 && length(lambda_list)==1
  sigma_chosen=sigma_list;
  lambda_chosen=lambda_list;
  score_cv=-inf;
else
  %%%%%%%%%%%%%%%% Searching Gaussian kernel width `sigma_chosen'
  %%%%%%%%%%%%%%%% and regularization parameter `lambda_chosen' 
  fold_index=[1:fold];
  cv_index=randperm(n);
  cv_split=floor([0:n-1]*fold./n)+1;
  scores_cv=zeros(length(sigma_list),length(lambda_list));

  for sigma_index=1:length(sigma_list)
    sigma=sigma_list(sigma_index);
    Phix_sigma=GaussBasis(Phix_tmp,sigma); % Phix_sigma is b x n
    
    if ~deltakernel 
        Phiy_sigma=GaussBasis(Phiy_tmp,sigma);
    end
        
    Phi_sigma=Phix_sigma.*Phiy_sigma; % Phi_sigma is b x n

    for i=fold_index
      cv_index_tmp=cv_index(cv_split==i);
      HH_cv_Phix(:,:,i)=Phix_sigma(:,cv_index_tmp)*Phix_sigma(:,cv_index_tmp)';
      HH_cv_Phiy(:,:,i)=Phiy_sigma(:,cv_index_tmp)*Phiy_sigma(:,cv_index_tmp)';
      hh_cv(:,:,i)=mean(Phi_sigma(:,cv_index_tmp),2);
      n_cv(i)=length(cv_index_tmp);
    end

    for i=fold_index
      cv_index_tr=fold_index(fold_index~=i);
      Hh_cv_tr=sum(HH_cv_Phix(:,:,cv_index_tr),3) ...
               .*sum(HH_cv_Phiy(:,:,cv_index_tr),3)/(sum(n_cv(cv_index_tr))^2);
      Hh_cv_te=HH_cv_Phix(:,:,i).*HH_cv_Phiy(:,:,i)/(n_cv(i)^2);
      hh_cv_tr=mean(hh_cv(:,:,cv_index_tr),3); % Mean of means, is it fine ??
      hh_cv_te=hh_cv(:,:,i);
      for lambda_index=1:length(lambda_list)
        lambda=lambda_list(lambda_index);
        alphah_cv=mylinsolve(Hh_cv_tr+lambda*eye(b),hh_cv_tr);
        wh_cv=alphah_cv'*Hh_cv_te*alphah_cv/2-hh_cv_te'*alphah_cv;
        scores_cv(sigma_index,lambda_index)=scores_cv(sigma_index,lambda_index)+wh_cv/fold;
      end % fold
    end % lambda
  end % sigma
  [scores_cv_tmp,lambda_chosen_index]=min(scores_cv,[],2);
  [score_cv,sigma_chosen_index]=min(scores_cv_tmp);
  lambda_chosen=lambda_list(lambda_chosen_index(sigma_chosen_index));
  %lambda_chosen
  sigma_chosen=sigma_list(sigma_chosen_index);
  %sigma_chosen
end %length(sigma_list)==1 && length(lambda_list)==1

%%%%%%%%%%%%%%%% Computing the final solution `MIh'
Phix=GaussBasis(Phix_tmp,sigma_chosen);
if ~deltakernel 
  Phiy=GaussBasis(Phiy_tmp,sigma_chosen);
end
Phi=Phix.*Phiy;
Hh=(Phix*Phix').*(Phiy*Phiy')/(n^2);
hh=mean(Phi,2);
alphah=mylinsolve(Hh+lambda_chosen*eye(b),hh);

% MIh=hh'*alphah-alphah'*Hh*alphah/2-1/2;

%MIh=alphah'*Hh*alphah/2-(mean(Phix,2).*mean(Phiy,2))'*alphah+1/2;
MIh=hh'*alphah/2-1/2;

