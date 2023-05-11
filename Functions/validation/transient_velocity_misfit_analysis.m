function [transient_errors, interp_data, indeces_start] = transient_velocity_misfit_analysis(md, id)
    axes = 1.0e+06 .* [0.45    0.50   -2.3   -2.25];

    t_model = [md.results.TransientSolution.time];
    vel_model = [md.results.TransientSolution.Vel];
    measure_obs = load('/data/eigil/work/lia_kq/Data/validation/velocity/velObs_onmesh.mat');
    indeces_start = find_closest_times(t_model, measure_obs.TStart);
    ice_levelset = [md.results.TransientSolution(:).MaskIceLevelset];
    transient_errors = get_transient_vel_errors(vel_model, measure_obs.vel_onmesh, t_model, measure_obs.TStart, measure_obs.TEnd, ice_levelset, 'closest');

%% compute transient velocity misfit boxplot per month
    % dates = datetime(datestr(decyear2date(t_model(indeces_start))));
    % [val, ind] = sort(dates.Month);
    % month_names = datestr(dates.Month, 'mmm');
    % monthly_error_vector = [];
    % grouping_vector = [];
    % n_means = [];
    % for i = 1:12
    %     monthly_error = transient_errors(:, dates.Month == i);
    %     [~, monthly_mean_error, ~] = integrateOverDomain(md, monthly_error, md.results.TransientSolution(indeces_start(i)).MaskIceLevelset>0);
    %     monthly_error_vector = [monthly_error_vector; monthly_mean_error'];
    %     month_ = dates(dates.Month==i);
    %     month_ = datestr(month_(1), 'mmm');
    %     month_name_vector = repmat({month_}, length(monthly_mean_error), 1);
    %     grouping_vector = [grouping_vector; month_name_vector];
    % end
    % figure(342)
    % boxplot(monthly_error_vector, grouping_vector)
    % ylim([-700, 700])

    
%% compute transient velocity misfit along flowline
    %%% PLOTTING IDEAS: 
    %%% 1) plot each flowline as row of pixels, with time on x-axis and distance on y-axis, colorbar for misfit
    %%% 2) plot each flowline on regular plot, and select gradient colorbar
    fl = load('/data/eigil/work/lia_kq/Data/validation/flowline_positions/central_flowline.mat', 'flowlineList');
    x_flowline = fl.flowlineList{1}.x;
    y_flowline = fl.flowlineList{1}.y;
    its_live_yearly = load('/data/eigil/work/lia_kq/Data/validation/velocity/its_live_onmesh.mat');
    vel_data = its_live_yearly.interp_vel;
    years = 1985:2018;
    transient_errors = get_transient_vel_errors(vel_model, vel_data, t_model, years, [], ice_levelset, 'yearly');
    interp_data = zeros(length(x_flowline), length(years));

    for i=1:length(years)
        interp_data(:, i) = interpToFlowline(md.mesh.x, md.mesh.y, transient_errors(:, i), x_flowline, y_flowline);
    end

    % filter nans
    first_data_row = zeros(50, length(years));
    last_data_row = zeros(1, length(years));
    buffer = 3; 

    for i=1:length(years)
        not_nan = ~isnan(interp_data(:, i));
        first_data_row(:, i) = find(not_nan, 50, 'first');
        last_data_row(i) = find(not_nan, 1, 'last') - buffer; % 5 is a buffer
        interp_data(last_data_row:end, i) = nan;
    end
    interp_data = interp_data(max(first_data_row):max(last_data_row) - buffer, :);
    x_flowline = x_flowline(max(first_data_row):max(last_data_row) - buffer);
    y_flowline = y_flowline(max(first_data_row):max(last_data_row) - buffer);
    distance = cumsum([0; sqrt((x_flowline(2:end) - x_flowline(1:end-1)) .^ 2 + (y_flowline(2:end) - y_flowline(1:end-1)) .^ 2)]') / 1000;
    distance  = abs(max(distance) - distance);

    figure(326);
    subplot(2,1,1)
    imagesc(interp_data);
    title('flowline misfit')
    colormap('turbo');
    c = colorbar();
    c.Label.String = 'Velocity misfit (m/yr)';

    caxis([-2000 2000])
    set(gca, 'YDir', 'normal');
    xticks(1:length(years));
    xticklabels(years);
    yticks(1:10:length(x_flowline));
    yticklabels(round(distance(1:10:end), 1));
    xlabel('Year');
    ylabel('Distance along flowline (km)');

    subplot(2,1,2)
    imagesc(log10(abs(interp_data) + 1));
    title('log10(abs(misfit) + 1)')
    colormap('turbo');
    c = colorbar();
    c.Label.String = "log10(Velocity misfit) (m/yr)";

    set(gca, 'YDir', 'normal');
    xticks(1:length(years));
    xticklabels(years);
    yticks(1:10:length(x_flowline));
    yticklabels(round(distance(1:10:end), 1));
    xlabel('Year');
    ylabel('Distance along flowline (km)');

    % for i=1:length(years)
    %     iclvl = logical(sum(ice_levelset(:, round(t_model) == years(i)) < 0, 2));
    %     plotmodel(md, 'data', transient_errors(:, i), 'axis', axes, 'mask', iclvl, 'title', num2str(years(i)), 'caxis', [-1000, 1000]); 
    %     hold on; plot(x_flowline, y_flowline, 'x-')
    %     % exportgraphics(gcf, ['/data/eigil/work/lia_kq/vel_obs_' num2str(years(i)) '.png'])
    %     % pause
    % end
%% compute transient velocity misfit movie
    % movie_vel_transient_error(md, id);

end