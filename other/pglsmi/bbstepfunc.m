function [step] = bbstepfunc( info )
%
% Function to find step size using f Barzilai and Borwein’s approach.
% 
% info = struct('k', k, 'W_k', W_k, 'Gw', Gw, 'W_p', W_p , 'Gw_p', Gw_p);
% ftp://netlib.amss.ac.cn/pub/yyx/papers/p0504.pdf
% 

S_k = info.W_k - info.W_p;
Y_k = info.Gw - info.Gw_p;
% step = (S_k'*Y_k)/(Y_k'*Y_k);
% step = (S_k'*S_k)/(S_k'*Y_k);
step = abs((S_k'*S_k)/(S_k'*Y_k));

if step == 0 || isnan(step)
    step = 1;
end


end

