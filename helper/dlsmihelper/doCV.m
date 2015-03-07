function do = doCV(refInfo, options)
%
% A function to check whether CV should be done in this iteration.
%

    OS = OptSignals();
    signal = refInfo.obj.signal;
    if signal == OS.INIT_CALL || signal == OS.NON_PARAM_CALL
        do = true;
        return;
    end
    
    if signal == OS.INIT_LINE_SEARCH || signal == OS.GENERAL_CALL
        bootingcvs = options.bootingcvs;
        cvevery = options.cvevery;
        iteration = refInfo.obj.iteration;
        do = iteration <= bootingcvs || ...
            mod(iteration - bootingcvs, cvevery) == 0;
        return;
    end
    do = false;    
end


