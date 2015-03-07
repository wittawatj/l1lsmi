function [ newname] = artMap( name )
%
% Function to change the name of artificial datasets.

old = {'3clusters2', '3clusters1', 'sca3', 'andor'};
new = {'3clusters', '3clusters', 'quad', 'and-or'};

M = containers.Map(old, new);
if M.isKey(name)
    newname = M(name);
else
    newname = name;
end
    

end

