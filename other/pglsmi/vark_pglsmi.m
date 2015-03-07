function VK = vark_pglsmi(X, Y, options )
%
% vark function returns a VK struct. 
%

options.wlearner = @pglsmi;

VK = vark_pg(X, Y, options );

end


