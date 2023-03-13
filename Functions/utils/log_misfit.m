function [log_error] = log_misfit(a, b, mask)

    log_error = (log10((a + 1e-10) ./ (b + 1e-10))).^2;
    log_error(mask) = log10(1e-10);
    
    if sum(log_error == Inf) ~= 0
        log_error(log_error == Inf) = log10(1e-10);

        % If there is more than 10% Inf ignore misfit
        if sum(log_error == Inf) / length(LIA_log_misfit) > 0.1
            log_error = NaN;
        end
    end

end