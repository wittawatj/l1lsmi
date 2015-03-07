
linestyles = cellstr(char('-','--','-.','--','-',':','-.','-','--',':','-',':',...
'-.','--','-',':','-.',':','-',':','-.', ...
'-', ':', '--', '-.' , ':', '--' ,'-' ,'-.', '--',':'));


MarkerEdgeColors=['r','b','m','y','c','b','r',...
'b','m','k','c','g','r','b','m','k','c','g',...
'r','c','b','k','g','m','r','b','m','k','c','g','r'];


Markers=['o','d','p','*','s','x','v','^','<','>','+','h','.',...
'+','*','o','x','^','<','h','.','>','p','s','d','v',...
'o','x','+','*','s','d','v','^','<','>','p','h','.'];

PlotStyle = cell(1,length(linestyles) );
for i=1:length(linestyles)
    PlotStyle{i}  = [linestyles{i} Markers(i) MarkerEdgeColors(i)];
end

