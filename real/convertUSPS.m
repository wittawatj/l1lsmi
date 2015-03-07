function [ X,Y] = convertUSPS( data, n)
%
% Convert USPS data which is in 3-d array form featurexsamplexdigit
% into X,Y where Y is from 1 to 10 with 1 for digit 1, 2 for digit 2 ...
% and 10 for digit 0
%
[m, nsamples, labels] = size(data);

classSamples = min(n/labels, nsamples);
Ind = randperm(nsamples);
Ind = Ind(1:classSamples);

data = data(:, Ind,:);
X = double(data(:,:));
Y = reshape(repmat(1:labels, classSamples, 1), 1, labels*classSamples);

% Shuffle X and Y
SInd = randperm(size(X,2));
X = X(:, SInd);
Y = Y(SInd);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

