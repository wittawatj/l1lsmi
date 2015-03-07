function [ X,Y] = subclassMulticlass( X,Y, classes )
% Make a new multiclass dataset by choosing only specified classes.
%

Ind = ismember(Y, classes);
X1 = X(:,Ind);
Y1 = Y(Ind);

RInd = randperm(size(X1,2));
X = X1(:, RInd);
Y = Y1(:, RInd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

