function  plot2dlabels( X,Y, usecurfigure)
% Plot multi-class 2D data
% Y can be shorter than X

if nargin < 3
    usecurfigure = true;
end

Uy  = unique(Y);
plotstyles

if ~usecurfigure
    figure 
end

hold on 

L = cell(1,length(Uy));
for yi=1:length(Uy)
    y = Uy(yi);
    Ind = Y==y;
    plot(X(1,Ind), X(2,Ind), Markers(yi), 'MarkerSize', 12, ...
    'MarkerFaceColor', MarkerEdgeColors(yi), ...
    'MarkerEdgeColor', MarkerEdgeColors(yi) )
    L{yi} = sprintf('class %d', y);
end

if length(Y) < size(X,2)
    % there are some unlabeled points
    plot(X(1,(length(Y)+1):end), X(2,(length(Y)+1):end), 'xk',...
        'MarkerSize', 7);
    legend([L {'unlabeled'} ]);
else
    legend(L);
end

% grid on
box on
hold off
daspect([1 1  1])


end
