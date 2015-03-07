function [MIh, score_cv] =MLMI(x,y,y_type,sigma_list,b,fold)
%
% Maximum Likelihood Mutual Information (with likelihood cross validation)
%
% Estimating mutual information 
%    \int\int p_{xy}(x,y) \frac{p_{xy}(x,y)}{p_x(x)p_y(y)} dx dy
% from input-output samples
%    { (x_i,y_i) | x_i\in R^{dx}, y_i\in R^{dy} }_{i=1}^n 
% drawn independently from a joint density p_{xy}(x,y).
% p_x(x) and p_y(y) are marginal densities of x and y, respectively.
% 
% Usage:
%       [MIh, score_cv] =MLMI(x,y,y_type,sigma_list,b)
%
% Input:
%    x         : dx by n input sample matrix
%    y         : dy by n output sample matrix
%    y_type     : if y_type=1, delta kernel is used for y; 
%                 otherwise (or empty) Gaussian kernel is used.
%    sigma_list: (candidates of) Gaussian width
%                If sigma_list is a vector, one of them is selected by cross validation.
%                If sigma_list is a scalar, this value is used without cross validation
%                If sigma_list is empty/undefined, Gaussian width is chosen from
%                some default canditate list by cross validation
%    b         : number of Gaussian centers (if empty, b=200 is used);
%
% Output:
%    MIh       : estimated mutual information between x and y
%    score_cv  : cross validation score
%
% (c) Taiji Suzuki, Department of Mathematical Informatics, The University of Tokyo, Japan. 
%     Masashi Sugiyama, Department of Compter Science, Tokyo Institute of Technology, Japan.
%     s-taiji@stat.t.u-tokyo.ac.jp
%     sugi@cs.titech.ac.jp,

global mytol
mytol = 10^(-15);

if nargin<2
  error('number of input arguments is not enough!!!')
end

n =size(x,2);
ny=size(y,2);
if n~=ny
  error('numbers of samples of x and y must be the same!!!')
end

if nargin<3
  y_type=0;
end

if nargin < 4 || isempty(sigma_list)
  sigma_list=logspace(-2,2,9);
end

if nargin < 5 || isempty(b)
  b = 200;
end  

if nargin < 6 || isempty(fold)
  fold=5;
end  

b=min(n,b);

%Gaussian centers are randomly chosen from samples
rand_index=randperm(n);
u=x(:,rand_index(1:b));
v=y(:,rand_index(1:b));

dy=size(y,1);
Phi_tmp =GaussBasis_sub([x;y],[u;v])';
Phix_tmp=GaussBasis_sub(x,u)';
if y_type==0
  Phiy_tmp=GaussBasis_sub(y,v)';
end

if length(sigma_list)==1 
  sigma_chosen=sigma_list; %no cross validation
  score_cv=-inf;
else %Choose sigma by cross validation
  fold_index=[1:fold];
  cv_index=randperm(n);
  cv_split=floor([0:n-1]*fold./n)+1;
  scores_cv=zeros(length(sigma_list),1);
  
  for sigma_index=1:length(sigma_list)
    sigma=sigma_list(sigma_index);
    Phix_sigma=GaussBasis(Phix_tmp,sigma);
    if y_type
      Phiy_sigma=DeltaBasis(y,v);
    else
      Phiy_sigma=GaussBasis(Phiy_tmp,sigma);
    end
    Phi_sigma=Phix_sigma.*Phiy_sigma;

    for i=1:fold
      cv_index_tmp=cv_index(cv_split==i);
      bbx(:,i)=sum(Phix_sigma(:,cv_index_tmp),2);
      bby(:,i)=sum(Phiy_sigma(:,cv_index_tmp),2);
      bbxy(:,i)=sum(Phix_sigma(:,cv_index_tmp).*Phiy_sigma(:,cv_index_tmp),2);
      n_cv(i)=length(cv_index_tmp);
    end
    
    for i=1:fold
      cv_index_tr=fold_index(fold_index~=i);
      n_cv_tr=sum(n_cv(cv_index_tr));
      bb=(sum(bbx(:,cv_index_tr),2).*sum(bby(:,cv_index_tr),2)...
          -sum(bbxy(:,cv_index_tr),2))/((n_cv_tr-1)*n_cv_tr);
      alphah_cv=KLIEP_learning(bb,Phi_sigma(:,cv_index(cv_split~=i))');
      wh_cv=alphah_cv'*Phi_sigma(:,cv_index(cv_split==i));
      scores_cv(sigma_index)=scores_cv(sigma_index)+mean(log(wh_cv(wh_cv>mytol)))/fold;
    end %fold
  end %sigma_index
  
  scores_cv(find(isnan(scores_cv)))=-Inf;
  [score_cv,sigma_index_cv]=max(scores_cv);
  sigma_chosen=sigma_list(sigma_index_cv(1));
end 

%%%%%%%%%%%%%%%% Computing the final solution `MIh'
Phix=GaussBasis(Phix_tmp,sigma_chosen);
if y_type
  Phiy=DeltaBasis(y,v);
else
  Phiy=GaussBasis(Phiy_tmp,sigma_chosen);
end
Phi=Phix.*Phiy;
bb=(sum(Phix,2).*sum(Phiy,2) - sum(Phix.*Phiy,2))/(n*(n-1));
alphah=KLIEP_learning(bb,Phi');
wh=alphah'*Phi;
MIh=mean(log(wh(wh>mytol)));
