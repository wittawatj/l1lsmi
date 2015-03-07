function do = useMedHeu(refInfo, options)
%
% A function to check whether median heuristic should be used in this iteration
% 

    OS = OptSignals();
    signal = refInfo.obj.signal;
    if signal == OS.INIT_CALL || signal == OS.NON_PARAM_CALL
        do = true;
        return;
    end
    
    if signal == OS.INIT_LINE_SEARCH || signal == OS.GENERAL_CALL
        bootingmedheu = options.bootingmedheu;
        medheuevery = options.medheuevery;
        iteration = refInfo.obj.iteration;
        do = iteration <= bootingmedheu || ...
            mod(iteration - bootingmedheu, medheuevery) == 0;
        return;
    end
    do = false;    
end

