function K = realK( m)
%
% Return the number of features k that should be selected for the given feature
% size 
%

if m <= 33
    K = 4; 
elseif m<=90
    K = 10;
else
    K= 20;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

