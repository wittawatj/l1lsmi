function [alpha,score]=KLIEP_learning(b,Xte,alpha0)
  
global mytol;
  ntr=length(b);
  [nte,nc]=size(Xte);
  
  max_iteration=100;
  epsilon_list=10.^[3:-1:-3];
  c=sum(b.^2);
  if nargin < 3
      alpha=ones(nc,1);
  else
      alpha=alpha0;
  end;
  [alpha,Xte_alpha,score]=KLIEP_projection(alpha,Xte,b,c);
  XXte = Xte*Xte';
  
  StoreEye = eye(nc);
  
  for epsilon=epsilon_list
    for iteration=1:max_iteration
      inwxte = 1./Xte_alpha;
      inwxte(Xte_alpha < mytol) = 0;
      ww = Xte'*inwxte;
      epsilon_scale = epsilon;
      alpha_tmp=alpha + epsilon_scale*ww;
      
      [alpha_new,Xte_alpha_new,score_new]=KLIEP_projection(alpha_tmp,Xte,b,c);
      if (score_new-score)<=0 
        break
      end
      score=score_new;
      alpha=alpha_new;
      Xte_alpha=Xte_alpha_new;
    end
  end
