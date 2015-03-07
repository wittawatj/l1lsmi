function barVTLogs( VTLogs, mti )
%
% Bar plot all VTV in a VTLogs. Call barVTV()
%
rows = 5;
cols = 1;

j=1;
for i=1:length(VTLogs)
    
    if mod(i-1, rows*cols) == 0
        figure
        j = 1;
    end
    subplot(rows, cols, j);
    
    VTV = VTLogs{i}.VTV;
    ti = sprintf('Restart: %d', i);
    barVTV(VTV, ti);
    
    j=j+1;
end

if nargin >=2 
    mtit(mti, 'yoff', .025);
end

end

