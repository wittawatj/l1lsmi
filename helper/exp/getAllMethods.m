function  Methods = getAllMethods(expNum)
%
% Get all methods run in the exp specified by expNum
%

Folders  = dir(sprintf('exp%sexp%d%s*-*', filesep, expNum, filesep));

Methods = cell(1);
for i=1:length(Folders)
    if Folders(i).isdir
        fname = Folders(i).name;
        Match = regexp(fname, '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)', 'names');
        Methods{end+1} = Match.method;
    end
end
Methods(1) = [];
Methods = unique(Methods);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

