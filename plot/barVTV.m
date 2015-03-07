function  h = barVTV(VTV, titlestr)
%
% Plot VTV in a bar-liked chart. 
% X-axis is v, Y-axis is features.
% This shows which features are selected as v is varied.
% VTV is a struct array with fields:
%  - W
%  - v
%  - f
%  - rankList
%
m = length(VTV(1).W);
CB = cellfun(@(rl)(binarizeRankList(rl,m)), {VTV.rankList}, ...
    'UniformOutput', false);

% Matrix. each column = selected features corresponding to one v
B = [CB{:}];

% Sort columns of B according to the values of v
[V, I] = sort([VTV.v]);
B = B(:, I);

% Flip dim1 so that feature #1 is at y=1
h = imagesc(~flipdim(B,1));
colormap gray


VLabels = arrayfun(@(v)(sprintf('%.2e',v)), V, 'UniformOutput', false);

set(gca, 'XTick', 1:length(VLabels));
set(gca, 'XTickLabel', VLabels);

fstep = 1+floor(m/10);
set(gca, 'YTick',  1:fstep:m);
set(gca, 'YTickLabel',  m:-fstep:1 );

if nargin >= 2
    title(titlestr);
end

end

function B=binarizeRankList(rankList, m)
    B = false(m,1);
    B(rankList) = true;
    
end

