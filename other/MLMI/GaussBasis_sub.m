function Phi_tmp=GaussBasis_sub(z,c)

  Phi_tmp=-(repmat(sum(c.^2,1),size(z,2),1) ...
	    +repmat(sum(z.^2,1)',1,size(c,2))-2*z'*c)/2;

