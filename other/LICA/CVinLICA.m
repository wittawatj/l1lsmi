function [sig,lambda] = CVinLICA(XLL,XV2,insigma,inlambda,dir_type,ind,FOLDNUM)

d = length(XV2);
n = size(XV2{1},1);

CV_SCORE = ones(length(insigma),length(inlambda))*Inf;
sigcount = 0;
for sig = insigma
    sigcount = sigcount + 1;

    GG = exp(- XLL/(2*sig^2)); 
    for l = 1:d
        Gmulti{l} = exp(-XV2{l}/(2*sig^2));
    end;
    
    lamcount = 0;
    for lam = inlambda 
        lamcount = lamcount + 1;
        val = CVVal(Gmulti,GG,lam,dir_type,FOLDNUM,ind);
        CV_SCORE(sigcount,lamcount) =  val;
    end;    
end;

[mm II] = min(CV_SCORE,[],1);
[m I] = min(mm);
sig = insigma(II(I));
lambda = inlambda(I);
