function [ X, Y, D ] = gen_3clusters1(n, seed)
%
% 3-class 3-dim classification dataset.
% The data is such that if consider only one dimension, then dim 3 is
% the best one. But, if we consider 2 dimensions, dim1 and dim2 combined
% are the best set. Treat feature 3 as the correct feature subset.
%
[ X, Y ] = meta_3clusters(n, seed);
D = {3};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
