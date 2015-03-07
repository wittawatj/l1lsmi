function S = fs_rhsic( X, Y, options )
%
% Ranking HSIC. Calculate HSIC between Xi and Y.
% Rank features based on the HSIC score.
%

k = options.k;

t0 = cputime;
tic;

HSIC = HSICEach(X,Y);
HSIC(isnan(HSIC)) = -inf;
[HSIC , HSICInd] = sort(HSIC, 'descend');

F = false(1 , size(X, 1) );
F(HSICInd(1:k) ) = true;

timetictoc = toc;
timecpu = cputime - t0;

S.timetictoc = timetictoc;
S.timecpu = timecpu;
S.F = F;
S.HSIC = HSIC;
S.HSICInd = HSICInd;


if sum(F) <= 6000
    S.redun_rate = redundancy_rate( X(F,:) , false);
    S.abs_redun_rate = redundancy_rate( X(F,:) , true);
end

end


function HSIC = HSICEach(X,Y)
% Return a score column vector
    if isclassification(X,Y) % assume classification
        hsic_func = @hsic_dis;
    else
        hsic_func = @hsic_cont;
    end
    
    [m n] = size(X);
    HSIC = zeros(m, 1 );
    for i = 1:m
        Xi = X(i,:);
        hs = hsic_func(Xi, Y);
        HSIC(i) = hs;
    end
    
end
