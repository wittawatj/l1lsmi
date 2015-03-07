function testl1ls()

m = 10;
X = randn(200,m);
Y = sum(X(:,1:4),2);
funObj = @(b)(makeFunc(b,X,Y));

v = 1;
B0 = 5*randn(m,1);
options = [];

% [B] = L1General2_OPG(funObj,B0, v*ones(m,1) , options);
% [B] = L1General2_TMP(funObj,B0, v*ones(m,1) , options);
% [Wh] = L1General2_BBSG(funObj,W0, v*ones(m,1) , options);
% [Wh] = L1General2_DSST(funObj,W0, v*ones(m,1) , options);
[B] = L1General2_PSSas(funObj,B0, v*ones(m,1) , options);
% [B] = L1General2_AS(funObj,B0, v*ones(m,1) , options);
% [Wh] = L1GeneralProjection(funObj,W0,v*ones(m,1), struct('order',-1));

B

end


function [f,g]=makeFunc(B,X,Y)
    D = X*B-Y;
    f = D'*D;
    g = 2*X'*D;
end