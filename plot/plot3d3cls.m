function  plot3d3cls( X,Y )
% Plot 3-class 3D data
msize = 14;
fontsize = 50;
Uy  = unique(Y);

%figure 
%clf

hold on 
Xy1 = X(:, Y == Uy(1));
Xy2 = X(:, Y == Uy(2));
Xy3 = X(:, Y == Uy(3));


plot3(Xy1(1,:), Xy1(2,:),Xy1(3,:),  'ob', 'MarkerSize', msize )
plot3(Xy2(1,:), Xy2(2,:), Xy2(3,:), 'xk', 'MarkerSize', msize )
plot3(Xy3(1,:), Xy3(2,:), Xy3(3,:), '*r', 'MarkerSize', msize )

grid on
box on
xlabel('X_1', 'FontSize', fontsize)
ylabel('X_2', 'FontSize', fontsize)
zlabel('X_3', 'FontSize', fontsize)
legend('Class 1', 'Class 2', 'Class 3')
hold off

daspect([1 1  1])

set(gca, 'FontSize', fontsize)

end

