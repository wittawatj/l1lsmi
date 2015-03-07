function str = kerfunc2str(kerFunc)
% 
% Kernel function to string
%

[ fname, param] = kerfuncexplode( func2str(kerFunc) );
str = sprintf('%s(%.3g)', fname, str2double(param));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

