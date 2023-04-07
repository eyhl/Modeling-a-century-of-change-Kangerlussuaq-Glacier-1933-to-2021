function [yearly_avg, first_index] = yearly_average(md, field, tstart, tstop)
    %% Compute yearly average of some field
    % md - model
    % field - field in model to average in time
    % tstart - first integer year
    % tstop - final integer year
    times = tstart:tstop;
    data_times = [md.results.TransientSolution(:).time];
    integer_years = floor(data_times);
    yearly_avg = zeros(size(field, 1) + 1, size(field, 2)); % to hold yearl averages
    first_index = zeros(size(tstart:tstop));
    for i=1:length(times)
        current_year = times(i) == integer_years;
        yearly_avg(1:end-1, i) = mean(field(:, current_year), 2);
        yearly_avg(end, i) = times(i);
        ind = find(current_year);
        first_index(i) = ind(1);
    end
end