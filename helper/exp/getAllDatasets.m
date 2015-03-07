function  Dats = getAllDatasets(expNum)
%
% Get all datasets run in the exp specified by expNum
%

Folders  = dir(sprintf('exp%sexp%d%s*-*', filesep, expNum, filesep));

Dats= cell(1);
for i=1:length(Folders)
    if Folders(i).isdir
        fname = Folders(i).name;
        Match = regexp(fname, '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)', 'names');
        Dats{end+1} = Match.data;
    end
end
Dats(1) = [];
Dats = unique(Dats);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

