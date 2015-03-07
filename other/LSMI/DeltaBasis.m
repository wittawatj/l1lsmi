function Phi=DeltaBasis(y,v)
Phi=zeros(length(v),length(y));
for yy=unique(y)
  Phi((v==yy),(y==yy))=1;
end
