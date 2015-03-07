function NewS = handles2str( S )
%
% Replace all function handles in the struct S with their string
% representations.
% 
Names = fieldnames(S);
for i=1:length(Names)
    N = Names{i};
    if isa( S.(N), 'function_handle')
        S.(N) = func2str(S.(N));
    end
end
NewS = S;

end

