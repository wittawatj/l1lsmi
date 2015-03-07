function Is_new = IsCalc(Hhat,hhat,alpha,lambda,dir_type)
    switch dir_type
        case 1
            Is_new = alpha'*Hhat*alpha/2 - hhat'*alpha;
        case 2
            Is_new = - hhat'*alpha/2 + 0.5;
        case 3
            Is_new = alpha'*Hhat*alpha/2 - hhat'*alpha;
        case 4
            Is_new = - hhat'*alpha/2 + 0.5;
        otherwise 
            Is_new = - hhat'*alpha/2 + 0.5;
    end;