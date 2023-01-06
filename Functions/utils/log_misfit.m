function [log_error] = log_misfit(md1, md2)

    log_error = ((md1.results.StressbalanceSolution.Vel + 1e-10) ./ (md2.results.StressbalanceSolution.Vel + 1e-10)).^2;
    log_error(md1.mask.ice_levelset>0) = log(1e-10);
    
    if sum(log_error == Inf) ~= 0
        log_error(log_error == Inf) = log(1e-10);

        % If there is more than 10% Inf ignore misfit
        if sum(log_error == Inf) / length(LIA_log_misfit) > 0.1
            log_error = Inf;
        end
    end

end