function I = straportion( Y, portion, seed)
%
% Stratified sampling.
% Perform subsampling on label vector Y in such a way that the class 
% proportion is maintained.  
% I is a binary row vector indicating which elements in Y are chosen.
%
% 0 < portion < 1
%
n = length(Y);

if portion <= 0 || portion > 1
    error('%s: portion must be between 0 and 1', mfilename);
end

oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          


I = false(1,n); % 1 byte per entry for logical matrix
UY = unique(Y);
for ui=1:length(UY)
    y = UY(ui);
    Indy = find(Y==y);
    lindy = length(Indy);
    Indy = Indy(randperm(lindy));
    
    % ceil guarantees that at least 1 instance will be chosen from each
    % class
    chosenI = Indy(1:ceil(portion*lindy)); 
    I(chosenI) = true;
    
end
RandStream.setDefaultStream(oldRs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end