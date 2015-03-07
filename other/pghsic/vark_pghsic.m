function VK = vark_pghsic(X, Y, options )
%
% vark function returns a VK struct. 
%

options.wlearner = @pghsic;

VK = vark_pg(X, Y, options );

end


