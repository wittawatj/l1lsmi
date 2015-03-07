function [alpha,Xte_alpha,score]=KLIEP_projection(alpha,Xte,b,c)
  
global mytol;

  c(abs(c)<10^(-20)) = Inf;
  
  alpha=alpha+b*(1-b'*alpha)/c;
  alpha=max(0,alpha);

  ww = b'*alpha;
  ww(abs(ww)<10^(-20)) = Inf;
  alpha=alpha/ww;
  Xte_alpha=Xte*alpha;
  score=mean(log(Xte_alpha(Xte_alpha>mytol)));
