function KP = kerPreGaussian(Centers, Samples)
% b x n matrix of intermediate result
% of basis expansion of Gaussian kernel
% (without exp and division by sigma part) 
%
    b = size(Centers,2);
    n = size(Samples,2);
   
    if false && exist('pdist2', 'file') % pdist2 is somehow slow on large dataset
        KP = -pdist2(Centers', Samples').^2;
    else
        D2 = bsxfun(@plus, sum(Centers.^2, 1)', sum(Samples.^2,1)) - 2*Centers'*Samples;
        KP = -D2;
        
    end
end

