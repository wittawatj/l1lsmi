function VK = vark_dhsic(X, Y, options )
%
% vark function returns a VK struct. 
%

options.wlearner = @dhsic;

VK = vark_d(X, Y, options );

end


