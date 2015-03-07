function W0 = zinitW( m, z, seed )
%
% FUnction to initialize W. 
% 

% Set the RandStream to use the seed
oldRs = RandStream.getGlobalStream();
rs = RandStream.create('mt19937ar','seed',seed);
RandStream.setGlobalStream(rs);        

W0 = 1+rand(m,1);
W0 = z*W0/sum(W0);

% W0 = z*rand(m, 1)+1;

% W0 = rand(m,1);

% Set RandStream back to its original one
RandStream.setGlobalStream(oldRs);

end

