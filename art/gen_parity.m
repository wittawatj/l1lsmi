function [ X, Y, D] = gen_parity( n, seed )
%
% Boolean variables. Target output is the number of 1's.
% Multiclass Classification.
%

% Set the RandStream to use the seed
oldRs = RandStream.getDefaultStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setDefaultStream(rs);          

XT = randi([0 1], 5, n); % 50%=1, 50%=0
XF = double(logical(randi([0 4], 5, n))); % 20%=1, 80%=0
XR = XT;

Ind = ~logical(randi([0 24], 1, numel(XT)));
XR(Ind) = ~XR(Ind);% redundant. Chance of bit flip = 4%
X = [XT;XR;XF];
Y = sum(XT,1);

D = {1:5};


% Set RandStream back to its original one
RandStream.setDefaultStream(oldRs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

