function k_radius = get_k_radius( X, Y, k)
%
% Calculate the appropriate k_radius given X,Y. k_radius is used in
% ztuner_seq_radius
% 
[m n] = size(X);
k_radius = max(floor(0.2*k), floor(m/20));


%%%%%%%%%%%%%%%%%%%
end

