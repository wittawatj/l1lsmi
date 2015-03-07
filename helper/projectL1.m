function w = projectL1(v, b)
%
% From
% http://www.cs.berkeley.edu/~jduchi/projects/DuchiShSiCh08.html
%
%


if (b < 0)
  error('Radius of L1 ball is negative: %2.3f\n', b);
end

u = sort(abs(v),'descend'); % Nuke: sort here is already mlog(m) ?
sv = cumsum(u);
rho = find(u > (sv - b) ./ (1:length(u))', 1, 'last');
theta = max(0, (sv(rho) - b) / rho);
w = sign(v) .* max(abs(v) - theta, 0);

