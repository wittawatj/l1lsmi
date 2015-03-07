function [sig,mixedsig,A] = DataGen(datatype,SampleNum)

switch datatype 
    case 1
        sig = rand(2,SampleNum);
        sig = sig - mean(sig,2)*ones(1,size(sig,2));
        A = [1 1;-1 1];
        mixedsig = A*sig;
    case 2
        sig = laprnd(2,SampleNum);
        sig = sig - mean(sig,2)*ones(1,size(sig,2));
        A = [1 1;-1 1];
        mixedsig = A*sig;
    case 3        
        sig(1,:) = rand(1,SampleNum);
        sig(2,:) = laprnd(1,SampleNum);
        sig = sig - mean(sig,2)*ones(1,size(sig,2));
        A = [1 1;-1 1];
        mixedsig = A*sig;
end;

