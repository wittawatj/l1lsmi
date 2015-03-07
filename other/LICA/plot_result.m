figure(1+datatype);
clf;
hold on;
Ainv = inv(A);

linewidth = 4;
for l = 1:2
    axisvec = 30*Ainv(l,:);
    plot([axisvec(1) -axisvec(1)],[axisvec(2) -axisvec(2)],'b--','LineWidth',linewidth*1.8);
end;
for l = 1:2 
    axisvec = 30*W(l,:);
    plot([axisvec(1) -axisvec(1)],[axisvec(2) -axisvec(2)],'k-','LineWidth',linewidth);
end;
plot(mixedsig(1,:),mixedsig(2,:),'*k');
for l = 1:2
    dis(l)  = max(mixedsig(l,:)) - min(mixedsig(l,:));
end;
ratio = 0.05;
axis([min(mixedsig(1,:))-ratio*dis(1) max(mixedsig(1,:))+ratio*dis(1) min(mixedsig(2,:))-ratio*dis(2) max(mixedsig(2,:))+ratio*dis(2)]);
set(gca,'FontName','Helvetica','FontSize',20);
box on;

