function [MIh,alphahy]=LSMIclassification(x,y,sigma_list,lambda_list,b)
%
% Least-Squares Mutual Information for classification
%
% Estimating a squared-loss variant of mutual information 
%    \frac{1}{2}\int\int (\frac{p(x,y)}{p(x)p(y)}-1)^2 p(x)p(y) dx dy
% from input-output samples
%    { (x_i,y_i) | x_i\in R^d, y_i\in{1,...,c} }_{i=1}^n 
% drawn independently from a joint density p(x,y).
% p(x) and p(y) are marginal densities of x and y, respectively.
% 
% Usage:
%       MIh=LSMIclassification(x,y,sigma_list,lambda_list,b)
%
% Input:
%    x          : d by n input sample matrix
%    y          : 1 by n label vector
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
%    b          : number of Gaussian centers (if empty, b=100 is used);
%
% Output:
%    MIh        : estimated mutual information between x and y
%
% (c) Masashi Sugiyama, Department of Compter Science, Tokyo Institute of Technology, Japan.
%     sugi@cs.titech.ac.jp,

if nargin < 3 || isempty(sigma_list)
  sigma_list=logspace(-2,2,9);
end
if nargin < 4 || isempty(lambda_list)
  lambda_list=logspace(-3,1,9);
end

if nargin<5 || isempty(b)
  b = 200;
end

[d,n]=size(x);
y_list=unique(y);
b=min(b,n);
tmp=randperm(n);
center_flag=zeros(1,n);
center_flag(tmp(1:b))=1;
for y_index=1:length(y_list)
  center_y=x(:,center_flag & y==y_list(y_index));
  data(y_index).dist2=repmat(sum(x.^2,1),[size(center_y,2) 1]) ...
	    +repmat(sum(center_y.^2,1)',[1 n])-2*center_y'*x;
end

fold=5;
fold_index=[1:fold];
if length(sigma_list)==1 && length(lambda_list)==1
  sigma_chosen=sigma_list;
  lambda_chosen=lambda_list;
else
  tmp=floor([0:n-1]*fold./n)+1;
  cv_index=tmp(randperm(n));
  n_cv=hist(cv_index,fold_index);
  for sigma_index=1:length(sigma_list)
    for y_index=1:length(y_list)
      Ky=exp(-data(y_index).dist2/(2*sigma_list(sigma_index)^2));
      cv_index_y=cv_index(y==y_list(y_index));
      clear Hhy_cv hhy_cv ny_cv
      for k=fold_index
        Hhy_cv(:,:,k)=Ky(:,cv_index==k)*Ky(:,cv_index==k)';
        hhy_cv(:,k)=sum(Ky(:,cv_index==k & y==y_list(y_index)),2);
        ny_cv(k)=sum(cv_index==k & y==y_list(y_index));
      end
      for k=fold_index
        Hhy_cv_tr=sum(Hhy_cv(:,:,fold_index~=k),3)...
                 *sum(ny_cv(fold_index~=k))/(sum(n_cv(fold_index~=k)))^2;
        hhy_cv_tr=sum(hhy_cv(:,fold_index~=k),2)/sum(n_cv(fold_index~=k));
        for lambda_index=1:length(lambda_list)
          alphahy_cv=mylinsolve(Hhy_cv_tr+lambda_list(lambda_index)*eye(size(Hhy_cv_tr,1)),...
                                hhy_cv_tr);
          scores_cv_all(sigma_index,lambda_index).score(k,y_index) ...
              =alphahy_cv'*Hhy_cv(:,:,k)*alphahy_cv/2*ny_cv(k)/(n_cv(k)^2)...
              -alphahy_cv'*hhy_cv(:,k)/n_cv(k);
        end % lambda
      end % k
    end % y_index
  end % sigma
  for sigma_index=1:length(sigma_list)
    for lambda_index=1:length(lambda_list)
      scores_cv(sigma_index,lambda_index) ...
          =sum(scores_cv_all(sigma_index,lambda_index).score(:))/fold-1/2;
    end % lambda
  end % sigma
  [scores_cv_tmp,lambda_chosen_index]=min(scores_cv,[],2);
  [score_cv,sigma_chosen_index]=min(scores_cv_tmp);
  lambda_chosen=lambda_list(lambda_chosen_index(sigma_chosen_index));
  sigma_chosen=sigma_list(sigma_chosen_index);

end %length(sigma_list)==1 && length(lambda_list)==1

%%%%%%%%%%%%%%%% Computing the final solution `MIh'

MIh=-1/2;
for y_index=1:length(y_list)
  Ky=exp(-data(y_index).dist2/(2*sigma_chosen^2));
  Hhy=Ky*Ky'*sum(y==y_list(y_index))/(n^2);
  hhy=sum(Ky(:,y==y_list(y_index)),2)/n;
  alphahy=mylinsolve(Hhy+lambda_chosen*eye(size(Hhy,1)),hhy);
  %MIh=MIh+hhy'*alphahy-alphahy'*Hhy*alphahy/2;
  %MIh=alphahy'*Hhy*alphahy/2-(mean(Phix,2).*mean(Phiy,2))'*alphahy+1/2;
  MIh=MIh+hhy'*alphahy/2;
end

