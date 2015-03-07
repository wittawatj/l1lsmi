function val = CVVal(Gmulti,GG,lam,dir_type,FOLDNUM,ind)

n = size(Gmulti{1},1);
d = length(Gmulti);

unitint = floor(n/FOLDNUM);
val = 0;
for ii = 1:FOLDNUM
    foldind = [1:(ii-1)*unitint ii*unitint+1:n];
    foldindrest = [(ii-1)*unitint + 1:ii*unitint];

    centfind = 1:length(ind);
    centind = centfind;

    hcros = Gmulti{1}(foldind,centfind)';
    for ll = 2:d
        hcros = hcros.*Gmulti{ll}(foldind,centfind)';
    end;
    hcros = mean(hcros,2);

    tmpfind = randperm(n);
    tmpfindrest = sort(tmpfind(1:unitint));
    tmpfinduse = sort(tmpfind(unitint+1:end));
    HCROS = Gmulti{1}(tmpfinduse,centfind)'*Gmulti{1}(tmpfinduse,centfind)/ length(tmpfinduse); 
    Hhatcros = Gmulti{1}(tmpfindrest,centfind)'*Gmulti{1}(tmpfindrest,centfind)/ length(tmpfindrest); 
    for ll = 2:d
        tmpfind = randperm(n);
        tmpfindrest = tmpfind(1:unitint);
        tmpfinduse = tmpfind(unitint+1:end);
        HCROS = HCROS.*(Gmulti{ll}(tmpfinduse,centfind)'*Gmulti{ll}(tmpfinduse,centfind))/length(tmpfinduse); 
        Hhatcros = Hhatcros.*(Gmulti{ll}(tmpfindrest,centfind)'*Gmulti{ll}(tmpfindrest,centfind))/length(tmpfindrest); 
    end;

    hhatcros = Gmulti{1}(foldindrest,centfind)';
    for ll = 2:d
        hhatcros = hhatcros.*Gmulti{ll}(foldindrest,centfind)';
    end;
    hhatcros = mean(hhatcros,2);

    btmp = size(HCROS,1);
    if dir_type == 3 || dir_type == 4
        RegMat = GG(ind(centind),centind) + 1e-8*eye(btmp,btmp); 
    else
        RegMat = eye(btmp,btmp);                    
    end;
    D = HCROS + lam*RegMat + 1e-8*eye(btmp,btmp);   
    alcros = D\hcros;
    val = val + IsCalc(Hhatcros,hhatcros,alcros,lam,dir_type);            
end;
val = val/FOLDNUM;
