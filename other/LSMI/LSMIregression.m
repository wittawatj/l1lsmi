function [MIh,score_cv]=LSMIregression(x,y,sigma_list,lambda_list,b)
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
%       [MIh,score_cv]=LSMI(x,y,y_type,sigma_list,lambda_list,b)
%
% Input:
%    x          : dx by n input sample matrix
%    y          : dy by n output sample matrix
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

if nargin<2
  error('number of input arguments is not enough!!!')
end

n =size(x,2);
ny=size(y,2);
if n ~= ny
  error('x and y must have the same number of samples!!!')
end;

if nargin < 3 || isempty(sigma_list)
  sigma_list=logspace(-2,2,9);
end
if nargin < 4 || isempty(lambda_list)
  lambda_list=logspace(-3,1,9);
end

if nargin<5 || isempty(b)
  b = 200;
end

b=min(n,b);

%Gaussian centers are randomly chosen from samples
rand_index=randperm(n);
u=x(:,rand_index(1:b));
v=y(:,rand_index(1:b));

dist2_x=repmat(sum(x.^2,1),[b 1])+repmat(sum(u.^2,1)',[1 n])-2*u'*x;
dist2_y=repmat(sum(y.^2,1),[b 1])+repmat(sum(v.^2,1)',[1 n])-2*v'*y;

if length(sigma_list)==1 && length(lambda_list)==1
  sigma_chosen=sigma_list;
  lambda_chosen=lambda_list;
  score_cv=-inf;
else
  %%%%%%%%%%%%%%%% Searching Gaussian kernel width `sigma_chosen'
  %%%%%%%%%%%%%%%% and regularization parameter `lambda_chosen' 
  fold=5;
  fold_index=[1:fold];
  tmp=floor([0:n-1]*fold./n)+1;
  cv_index=tmp(randperm(n));
  scores_cv=zeros(length(sigma_list),length(lambda_list));

  for sigma_index=1:length(sigma_list)
    Phix_sigma=exp(-dist2_x/(2*sigma_list(sigma_index)^2));
    Phiy_sigma=exp(-dist2_y/(2*sigma_list(sigma_index)^2));
    Phi_sigma=Phix_sigma.*Phiy_sigma;
    for i=fold_index
      HH_cv_Phix(:,:,i)=Phix_sigma(:,cv_index==i)*Phix_sigma(:,cv_index==i)';
      HH_cv_Phiy(:,:,i)=Phiy_sigma(:,cv_index==i)*Phiy_sigma(:,cv_index==i)';
      hh_cv(:,:,i)=mean(Phi_sigma(:,cv_index==i),2);
      n_cv(i)=sum(cv_index==i);
    end
    for i=fold_index
      Hh_cv_tr=sum(HH_cv_Phix(:,:,fold_index~=i),3) ...
               .*sum(HH_cv_Phiy(:,:,fold_index~=i),3)/(sum(n_cv(fold_index~=i))^2);
      Hh_cv_te=HH_cv_Phix(:,:,i).*HH_cv_Phiy(:,:,i)/(n_cv(i)^2);
      hh_cv_tr=mean(hh_cv(:,:,fold_index~=i),3);
      hh_cv_te=hh_cv(:,:,i);
      for lambda_index=1:length(lambda_list)
        alphah_cv=mylinsolve(Hh_cv_tr+lambda_list(lambda_index)*eye(b),hh_cv_tr);
        wh_cv=alphah_cv'*Hh_cv_te*alphah_cv/2-hh_cv_te'*alphah_cv;
        scores_cv(sigma_index,lambda_index)=scores_cv(sigma_index,lambda_index)+wh_cv/fold;
      end % fold
    end % lambda
  end % sigma
  [scores_cv_tmp,lambda_chosen_index]=min(scores_cv,[],2);
  [score_cv,sigma_chosen_index]=min(scores_cv_tmp);
  lambda_chosen=lambda_list(lambda_chosen_index(sigma_chosen_index));
  sigma_chosen=sigma_list(sigma_chosen_index);
end %length(sigma_list)==1 && length(lambda_list)==1

%%%%%%%%%%%%%%%% Computing the final solution `MIh'
Phix=exp(-dist2_x/(2*sigma_chosen^2));
Phiy=exp(-dist2_y/(2*sigma_chosen^2));
Phi=Phix.*Phiy;
Hh=(Phix*Phix').*(Phiy*Phiy')/(n^2);
hh=mean(Phi,2);
alphah=mylinsolve(Hh+lambda_chosen*eye(b),hh);
%MIh=hh'*alphah-alphah'*Hh*alphah/2-1/2;
%MIh=alphah'*Hh*alphah/2-(mean(Phix,2).*mean(Phiy,2))'*alphah+1/2;
MIh=hh'*alphah/2-1/2;

