function  Trials = getAllTrials(expnum, dataset, method)
%
% Get all trials run in the exp specified by expnum, dataset, method.
%

Results = dir(sprintf('exp%sexp%d%s%s-%s%s*-*.mat', filesep, expnum, filesep, ...
    dataset, method, filesep));

Trials = zeros(length(Results), 1);
for i=1:length(Results)
    
    fname = Results(i).name;
    Match = regexp(fname, ...
        '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)[-](?<trial>\d+)', 'names');
    Trials(i) = str2num(Match.trial);
    
end
Trials = sort(Trials);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

