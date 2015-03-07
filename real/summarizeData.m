function summarizeData(folder, dest)
%
% Display size, dimensions, classes in a table. 
%

Files = dir([folder '/*.mat']);
Data = cell(1,1);
for fi=1:length(Files)
    F = Files(fi);
    load(sprintf('%s/%s', folder, F.name))
    if exist('X','var') && exist('Y', 'var')
        [m n] = size(X);
        if m <= 1 % threshold to calculate pairwise correlation 
            redun = redundancy_rate(X);
            aredun = redundancy_rate(X, true);
        else
            redun = '?';
            aredun = '?';
        end
        
        if isclassification(X, Y)
            c = length(unique(Y));
            T = tabulate(Y);
            prop = arrayfun(@(x)(sprintf('%.1f ',x)) ,T(:,3),'UniformOutput',false);
            prop = [prop{:}];

            Data{fi,1} = F.name;
            Data{fi,2} = m;
            Data{fi,3} = n;
            if c==2
                t = 'B';
            else
                t = sprintf('M%d', c);
            end
            Data{fi,4} = t;
            Data{fi,5} = redun;
            Data{fi,6} = aredun;
            Data{fi,7} = prop;
        
        else % regression
            Data{fi,1} = F.name;
            Data{fi,2} = m;
            Data{fi,3} = n;
            Data{fi,4} = 'R';
            Data{fi,5} = redun;
            Data{fi,6} = aredun;
            Data{fi,7} = '';
        end
        
        
    end
end
Labels = {'name','m','n','Task','Redundancy rate','Absolute redundancy rate', 'Note'};
cell2csv(dest, [Labels; Data], ';');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

