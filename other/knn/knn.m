function [eY,I] = knn(Xtr, Ytr, Xte, k)
%  
% Return estimated labels of Xte using k-NN.
% Xtr is dxn where d is dimensions, and n is number of samples.
% Ytr is n dimensional row vector. 
%

if exist('pdist2','file')
    [D I] = pdist2(Xtr', Xte','euclidean','SMALLEST',k);
else
    D = ipdm(Xtr', Xte');
    [V I] = sort(D,1);
    
end
I = I(1:k, :);
neighborY = Ytr(I);
eY = mode(neighborY,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end