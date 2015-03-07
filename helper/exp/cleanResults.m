function  cleanResults( expNum)
%
% - Replace variable X in all mat files in the specified folder with an empty
% matrix []. This is to reduce space usage.
% - Try to eliminate function handles
%

base = sprintf('exp/exp%d', expNum);

expFolders = dir(fullfile(base, '*-*'));

for i=1:length(expFolders)
    fol = expFolders(i);
    folPath = fullfile(base, fol.name);
    matFiles = dir(fullfile(folPath, '*.mat'));
    for j=1:length(matFiles)
        matf = matFiles(j);
        matPath = fullfile(folPath, matf.name);
%         display(matPath);
        
        L = load(matPath);
        if isfield(L, 'X')
            L=rmfield(L, 'X');
        end
        if isfield(L, 'o')
            % replace function handles in o with strings
            L.o = handles2str(L.o);
        end
        
        if isfield(L, 'S') && isfield(L.S, 'ZTLogs')
            for i=1:length(L.S.ZTLogs)
                L.S.ZTLogs{i}.options = handles2str(L.S.ZTLogs{i}.options);
            end
        end
        save(matPath, '-struct', 'L' );
        display(sprintf('Cleaned results in %s', matPath));
    end
end


%%%%%%%%%%%%%%%%%%
end

