function C = outeropt( A, B, f )
% 
% Outer operator. Much like outer product of two vectors but the product
% part can be replaced with any general function taking 2 numbers.
% Inputs are forced vectorized.
%  
% f = function handle 
% C = a matrix of size(length(A(:)), length(B(:)))
% 

    C = bsxfun(f, A(:), B(:)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

