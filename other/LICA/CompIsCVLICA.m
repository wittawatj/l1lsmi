function val = CompIsCVLICA(XLL,XV2,sig,lambda,dir_type,ind,FOLDNUM)

d = length(XV2);

GG = exp(- XLL/(2*sig^2)); 
for l = 1:d
    Gmulti{l} = exp(-XV2{l}/(2*sig^2));
end;

val = CVVal(Gmulti,GG,lambda,dir_type,FOLDNUM,ind);