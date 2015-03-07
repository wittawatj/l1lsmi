function [GG,Gmulti,Gmulti2,Hhat,hhat] = CalcIsCVLICA(XLL,XV2,sig)

n = size(XV2{1},1);
d = length(XV2);

GG = exp(- XLL/(2*sig^2)); 
hhat = mean(GG,1)';
for l = 1:d
    Gmulti{l} = exp(-XV2{l}/(2*sig^2));
end;

b = size(Gmulti{1},2);
Hhat =  ones(b,b); 
for l = 1:d
    Gmulti2{l} = Gmulti{l}'*Gmulti{l}/n;
    Hhat = Gmulti2{l}.*Hhat;  
end;
