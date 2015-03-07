function I = strapartregression( n, fold, seed)
%
% Stratified partition.
% I is a foldxn binary fold indicator matrix.
%

if fold > n
    error('%s: fold should not be larger than n', mfilename);
end

oldRs = RandStream.getGlobalStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setGlobalStream(rs);          

I = false(fold,n); % 1 byte per entry for logical matrix
Ind = repmat(1:fold, ceil(n/fold),1)';
Ind = Ind(:);
Ind = Ind(1:n);
Ind = Ind(randperm(n));
for i=1:fold
    I(i,:) = Ind==i;
end

RandStream.setGlobalStream(oldRs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end