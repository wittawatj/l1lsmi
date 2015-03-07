clear all;

rand('state',0);
randn('state',0);

dataset=1;
switch dataset
 case 1 % dependent (regression)
  n=100;
  X=(rand(1,n)*2-1)*10;
  Y=sin(X(1,:)/10*pi);
  y_type=0; % regression
 case 2 % independent (regression)
  n=100;
  X=(rand(1,n)*2-1)*10;
  Y=(rand(1,n)*2-1);
  y_type=0; % regression
 case 3 % dependent (classification)
  n=100;
  X=[randn(1,n/2)-5 randn(1,n/2)+5];
  Y=[-ones(1,n/2) ones(1,n/2)];
  y_type=1; % classification
 case 4 % independent (classification)
  n=100;
  X=[randn(1,n/2)-5 randn(1,n/2)+5];
  Y=sign(randn(1,n));
  y_type=1; % classification
end

if y_type==0
  SMIh=LSMIregression(X,Y);
else
  SMIh=LSMIclassification(X,Y);
end

disp(sprintf('(Estimated SMI between x and y) = %g',SMIh));


%%%%%%%%%%%%%%%%%%%%%% Displaying original 2D data
figure(dataset)
clf
hold on

set(gca,'FontName','Helvetica')
set(gca,'FontSize',12)
plot(X,Y,'ro','LineWidth',1,'MarkerSize',8);
xlabel('x')
ylabel('y')
axis([-10 10 -1.2 1.2])
title(sprintf('(Estimated SMI between x and y) = %g',SMIh))

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 12 9]);
print('-depsc',sprintf('LSMI%g',dataset))
  
