function [X,Y,D] = gen_andor(n, seed)
% 
% And/or problem. Similar to the paper
% "Irrelevant features and the subset selection problem."
% 

% Set the RandStream to use the seed
oldRs = RandStream.getGlobalStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setGlobalStream(rs);          

X1 = randi([0 1], 1, n); % 50/50%
X2 = randi([0 1], 1, n); % 50/50%
X3 = randi([0 1], 1, n); % 50/50%
X4 = randi([0 1], 1, n); % 50/50%

% X12 = flip(and(X1,X2), 4); %20% flip
% X34 = flip(and(X3,X4), 4); %20% flip

XF = randi([0 1], 3, n); % 50/50%

Y = double(or(and(X1,X2), and(X3,X4)));
X5 = flip(Y, 4); %20% flip
X6 = flip(Y, 4); %20% flip
X7 = flip(Y, 4); %20% flip

X = [X1;X2;X3;X4;X5;X6;X7;XF];

D = {1:4};

% Set RandStream back to its original one
RandStream.setGlobalStream(oldRs);


end

function vec=flip(vec, to)
    ind = ~randi([0 to], 1, length(vec));
    vec(ind) = ~vec(ind);
    
end