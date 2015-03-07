function isclass = isclassification( X, Y)
% 
% Return true if the problem should be treated as classification problem.
% Note that this function should be used only when the task is not explicitly
% given. Most of the time, it should be explicitly given.
% 
% Assume that the class values of a classification task are encoded with
% integers. If the value of Y are float, assume a regression task.
% 

% isclass = size(Y,1) == 1 && length(unique(Y)) <= 40 ...
%     && max(Y) - min(Y) <= 40;

Y = double(Y);
isclass = size(Y,1) == 1 && norm(floor(Y)-Y) < 1e-8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

