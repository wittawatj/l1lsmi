UseSampleNums = [200];
DATATYPES = [1 2 3];

for UsingSampleNum = UseSampleNums
    for datatype = DATATYPES 
        [sig,mixedsig,A] = DataGen(datatype,UsingSampleNum);
        figure(1);
        clf;
        plot(mixedsig(1,:),mixedsig(2,:),'*');

        insigma = linspace(0.1,1,10);
        inlambda = logspace(-3,0,10);

        INPARAM.Emp_Cost = 2; 
        INPARAM.Reg_Term = 2;  
        [W,sigma,lambda,PARAMETERS,Wcand] = LICA(mixedsig,insigma,inlambda,300,INPARAM);
        
        plot_result;
    end;
end;

