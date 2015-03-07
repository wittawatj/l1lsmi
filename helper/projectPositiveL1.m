function w = projectPositiveL1(v, b)
%
% Modified the code from
% http://www.cs.berkeley.edu/~jduchi/projects/DuchiShSiCh08.html
%
% Nov 5, 2011
%

if (b < 0)
  error('Radius of L1 ball is negative: %2.3f\n', b);
end

v = max(v, 0);

w = projectL1(v, b);

