function [X,Y] = convertmulticlass( sample )
%
% sample is an array struct
%

X= [];
Y= [];
for i =1:length(sample)
    sx = sample(i).x';
    X = [X ,  sx];
    Y = [Y , i*ones(1 , size(sx,2) ) ];
end

[m n ] = size(X);
ind = randperm(n);
X = X(:, ind);
Y = Y(ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

