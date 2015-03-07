function NewS = remove_handles( S )
%
% Remove all function handles in the struct S
% 
Names = fieldnames(S);
for i=1:length(Names)
    N = Names{i};
    if isa( S.(N), 'function_handle')
        S = rmfield(S, N);
    end
end
NewS = S;

end

