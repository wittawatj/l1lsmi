function I = straportionreg( Y, portion, seed)
%
% Stratified sampling for regression
%
% 0 < portion < 1
%
n = length(Y);

if portion <= 0 || portion >= 1
    error('%s: portion must be between 0 and 1 (exclusive)', mfilename);
end

oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


I = false(1,n); % 1 byte per entry for logical matrix
Ind = randperm(n);
Ind = Ind(1:ceil(portion*n));
I(Ind) = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end