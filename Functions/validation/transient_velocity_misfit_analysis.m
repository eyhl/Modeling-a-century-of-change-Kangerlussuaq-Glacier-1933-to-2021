function [transient_errors, interp_data, indeces_start] = transient_velocity_misfit_analysis(md, id, movie, save_figures)
    if nargin < 4
        save_figures = false;
        if nargin < 3
            movie = false;
        end
    end
    % Get the screen size
    screensize = get(0, 'Screensize');

    % Set the default figure position
    set(groot, 'DefaultFigurePosition', screensize);

    axes = 1.0e+06 .* [0.45    0.50   -2.3   -2.25];

    % load fast flow domain for computing areas coverage
    domain_path = 'Exp/fast_flow/valid_elements_in_fast_flow.exp';
    domain_mask = ContourToNodes(md.mesh.x, md.mesh.y, domain_path, 2);

    t_model = [md.results.TransientSolution.time];
    vel_model = [md.results.TransientSolution.Vel];
    elev_model = [md.results.TransientSolution.Surface];
    measure_obs = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/velObs_onmesh.mat');
    fl = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/flowline_positions/central_flowline.mat', 'flowlineList');
    x_flowline = fl.flowlineList{1}.x;
    y_flowline = fl.flowlineList{1}.y;
    its_live_yearly = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/its_live_onmesh.mat');
    indeces_start = find_closest_times(t_model, measure_obs.TStart);
    ice_levelset = [md.results.TransientSolution(:).MaskIceLevelset];
    [transient_errors, ice_masks] = get_transient_vel_errors(vel_model, measure_obs.vel_onmesh, t_model, measure_obs.TStart, measure_obs.TEnd, ice_levelset, 'closest');


 %% ------------ PER MONTH ANALYSIS VELOCITY ------------
    % ---------- compute transient velocity misfit boxplot per month -------------
    dates = datetime(datestr(decyear2date(t_model(indeces_start))));
    [val, ind] = sort(dates.Month);
    month_names = datestr(dates.Month, 'mmm');
    monthly_error_vector = [];
    grouping_vector = [];
    n_means = [];
    months = 1:12;
    interp_data = zeros(length(x_flowline), length(months));
    monthly_average = zeros(size(transient_errors, 1), length(months));
    month_names = {};

    for i = months
        monthly_error = transient_errors(:, dates.Month == i);
        monthly_average(:, i) = mean(monthly_error, 2);
        [~, monthly_mean_error, ~] = integrateOverDomain(md, monthly_error, md.results.TransientSolution(indeces_start(i)).MaskIceLevelset>0);
        monthly_error_vector = [monthly_error_vector; monthly_mean_error'];
        month_ = dates(dates.Month==i);
        month_ = datestr(month_(1), 'mmm');
        month_name_vector = repmat({month_}, length(monthly_mean_error), 1);
        grouping_vector = [grouping_vector; month_name_vector];
        month_names{i} = month_;
    end

    figure(342)
    boxplot(monthly_error_vector, grouping_vector)
    ylim([-abs(max(monthly_error_vector)), max(abs(monthly_error_vector))])
    if save_figures
        exportgraphics(gcf, sprintf('Figure/velocity_misfit_boxplot_%s.png', id), 'Resolution', 300);
    end

    %  ---------- compute average flowline per month -------------
    for i=months
        interp_data(:, i) = interpToFlowline(md.mesh.x, md.mesh.y, monthly_average(:, i), x_flowline, y_flowline);
    end

    % filter nans
    first_data_row = zeros(1, length(months));
    last_data_row = zeros(1, length(months));
    buffer = 3; 

    for i=1:months
        not_nan = ~isnan(interp_data(:, i));
        first_data_row(:, i) = find(not_nan, 1, 'first');
        last_data_row(i) = find(not_nan, 1, 'last') - buffer; % 5 is a buffer
        interp_data(last_data_row:end, i) = nan;
    end

    interp_data = interp_data(max(first_data_row):max(last_data_row) - buffer, :);
    x_flowline = x_flowline(max(first_data_row):max(last_data_row) - buffer);
    y_flowline = y_flowline(max(first_data_row):max(last_data_row) - buffer);
    distance = cumsum([0; sqrt((x_flowline(2:end) - x_flowline(1:end-1)) .^ 2 + (y_flowline(2:end) - y_flowline(1:end-1)) .^ 2)]') / 1000;
    distance  = abs(max(distance) - distance);

    figure(325);
    subplot(2,1,1)
    imagesc(interp_data);
    title('Flowline misfit, monthly average 2006-2021')
    colormap('turbo');
    c = colorbar();
    c.Label.String = 'Velocity misfit (m/yr)';
    
    caxis([-750 750])
    set(gca, 'YDir', 'normal');
    xticks(1:length(months));
    xticklabels(month_names);
    yticks(1:10:length(x_flowline));
    yticklabels(round(distance(1:10:end), 1));
    xlabel('Month');
    ylabel('Distance along flowline (km)');

    subplot(2,1,2)
    imagesc(log10(abs(interp_data) + 1));
    title('log10(abs(misfit) + 1)')
    colormap('turbo');
    c = colorbar();
    c.Label.String = "log10(Velocity misfit) (m/yr)";

    set(gca, 'YDir', 'normal');
    xticks(1:length(months));
    xticklabels(month_names);
    yticks(1:10:length(x_flowline));
    yticklabels(round(distance(1:10:end), 1));
    xlabel('Month');
    ylabel('Distance along flowline (km)');
    if save_figures
        exportgraphics(gcf, sprintf('Figure/flowline_velocity_misfit_monthly_%s.png', id), 'Resolution', 300);
    end 
    %% compute transient velocity misfit movie
    if movie
        movie_vel_transient_error(md, transient_errors, t_model(indeces_start), ice_masks<0, ' Velocity misfit monthly', [-2000, 2000]);
    end

%% ------------ PER YEAR ANALYSIS VELOCITY ------------
    % ---------- compute transient velocity misfit along flowline -------------
    %%% PLOTTING IDEAS: 
    %%% 1) plot each flowline as row of pixels, with time on x-axis and distance on y-axis, colorbar for misfit
    %%% 2) plot each flowline on regular plot, and select gradient colorbar
    x_flowline = fl.flowlineList{1}.x;
    y_flowline = fl.flowlineList{1}.y;
    vel_data = its_live_yearly.interp_vel;
    years = 1985:2018;
    [transient_errors, ice_masks] = get_transient_vel_errors(vel_model, vel_data, t_model, years, [], ice_levelset, 'yearly');
    interp_data = zeros(length(x_flowline), length(years));
    % yearly_error_vector = [];
    % grouping_vector = [];
    find_years = floor(t_model);
    yearly_avg_vector = zeros(1, length(years));
    yearly_med_vector = zeros(1, length(years));
    yearly_std_vector = zeros(1, length(years));

    for i=1:length(years)
        error = transient_errors(:, i);
        ice_levelset_for_year = ice_levelset(:, find_years==i);
        ice_nodes = sum(ice_levelset(:, find_years==i)>0, 1);
        [~, most_retreated_index] = min(ice_nodes);
        ice_mask_for_year = logical(ice_levelset_for_year(:, most_retreated_index)>0);

        error(ice_mask_for_year) = nan;
        interp_data(:, i) = interpToFlowline(md.mesh.x, md.mesh.y, error, x_flowline, y_flowline);

        yearly_avg_vector(i) = mean(error, 'omitnan');
        yearly_med_vector(i) = median(error, 'omitnan');
        yearly_std_vector(i) = std(error, 'omitnan');

        % domain area coverage
        [~, ~, areas_domain, areas_masked] = get_data_on_elements(md, error, ~domain_mask);
        coverage(i) = 100 * round(sum(areas_masked, 'omitnan') / sum(areas_domain, 'omitnan'), 2);
        % [~, error, ~] = integrateOverDomain(md, error, ice_mask_for_year);
        % yearly_error_vector = [yearly_error_vector; error'];
        % yearly_name_vector = repmat(years(i), length(yearly_error_vector), 1);
        % grouping_vector = [grouping_vector; yearly_name_vector];
    end
    coverage = num2cell(coverage);
    for i=1:length(coverage)
        coverage{i} = append(num2str(coverage{i}), ' %');
    end
    
    % boxplot
    figure(344)
    errorbar(years, yearly_avg_vector, yearly_std_vector, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize',10)
    hold on;
    scatter(years, yearly_med_vector, 'rx');
    text(years, yearly_avg_vector - yearly_std_vector - 20, coverage, 'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', 10);
    legend('Mean +/- std. dev.', 'Median')
    grid on
    % boxplot(yearly_error_vector, grouping_vector)
    % X = [yearly_error_vector(:), grouping_vector];
    % hist3(X, 'Edges', {-100:1:100, (1985:1:2018)}, 'CDataMode', 'auto')
    % h = histogram2(yearly_error_vector(:), grouping_vector, -1000:10:1000, (1985:1:2018), 'DisplayStyle', 'tile','Normalization','probability', 'ShowEmptyBins','on')
    % yticklabels(1985:1:2018)
    ylabel('Mean Error')
    xlabel('time')
    xlim([1984, 2019])
    title('Summary statistics of velocity error per year (1985-2018)')
    subtitle('Percentage of valid area in fast flow domain shown below error bars')
    hold off
    if save_figures
        exportgraphics(gcf, sprintf('Figure/summary_stats_velocity_misfit_yearly_%s.png', id), 'Resolution', 300);
    end 

    % filter nans
    first_data_row = zeros(50, length(years));
    last_data_row = zeros(1, length(years));
    buffer = 3; 

    for i=1:length(years)
        not_nan = ~isnan(interp_data(:, i));
        first_data_row(:, i) = find(not_nan, 50, 'first');
        last_data_row(i) = find(not_nan, 1, 'last') - buffer; % 
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
    title('Flowline misfit yearly average 1985-2018')
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
    if save_figures
        exportgraphics(gcf, sprintf('Figure/flowline_velocity_misfit_yearly_%s.png', id), 'Resolution', 300);
    end

    % for i=1:length(years)
    %     iclvl = logical(sum(ice_levelset(:, round(t_model) == years(i)) < 0, 2));
    %     plotmodel(md, 'data', transient_errors(:, i), 'axis', axes, 'mask', iclvl, 'title', num2str(years(i)), 'caxis', [-1000, 1000]); 
    %     hold on; plot(x_flowline, y_flowline, 'x-')
    %     % exportgraphics(gcf, ['/home/eyhli/IceModeling/work/lia_kq/vel_obs_' num2str(years(i)) '.png'])
    %     % pause
    % end
%% compute transient velocity misfit movie
if movie
    movie_vel_transient_error(md, transient_errors, years, ice_masks<0, ' Velocity misfit yearly', [-2000, 2000]);
end



%% ------------ PER MONTH ANALYSIS ELEVATION ------------
    % ---------- compute transient velocity misfit boxplot per month -------------
    geoid = interpBmGreenland(md.mesh.x, md.mesh.y, 'geoid');
    cryosat_data = load("/home/eyhli/IceModeling/work/lia_kq/Data/validation/cryosat/cryosat_onmesh.mat");
    elev_data = cryosat_data.interpolated_surface - geoid;
    % indeces_start = find_closest_times(t_model, elev_data.);
    % dates = datetime(datestr(decyear2date(t_model(indeces_start)))); 
    % [val, ind] = sort(dates.Month);
    % month_names = datestr(dates.Month, 'mmm');
    x_flowline = fl.flowlineList{1}.x;
    y_flowline = fl.flowlineList{1}.y;

    monthly_error_vector = [];
    grouping_vector = [];
    n_means = [];
    interp_data = zeros(length(x_flowline), length(cryosat_data.times));
    month_names = {};
    [transient_errors, ice_masks] = get_transient_vel_errors(elev_model, elev_data, t_model, cryosat_data.times, [], ice_levelset, 'monthly');

    %  ---------- compute average flowline per month -------------
    for i=1:length(cryosat_data.times)
        interp_data(:, i) = interpToFlowline(md.mesh.x, md.mesh.y, transient_errors(:, i), x_flowline, y_flowline);
    end

    % filter nans
    first_data_row = zeros(1, length(cryosat_data.times));
    last_data_row = zeros(1, length(cryosat_data.times));
    buffer = 3; 

    for i=1:length(cryosat_data.times)
        not_nan = ~isnan(interp_data(:, i));
        first_data_row(:, i) = find(not_nan, 1, 'first');
        last_data_row(i) = find(not_nan, 1, 'last') - buffer; % 5 is a buffer
        interp_data(last_data_row:end, i) = nan;
    end

    interp_data = interp_data(10:105, :);
    x_flowline = x_flowline(10:105);
    y_flowline = y_flowline(10:105);
    distance = cumsum([0; sqrt((x_flowline(2:end) - x_flowline(1:end-1)) .^ 2 + (y_flowline(2:end) - y_flowline(1:end-1)) .^ 2)]') / 1000;
    distance  = abs(max(distance) - distance);

    dn = datenum(cryosat_data.times, 0, 0);                          
    [~, month_names, ~] = datevec(dn);

    figure(325);
    subplot(2,1,1)
    imagesc(interp_data);
    title('Flowline misfit, monthly average 2010-2021')
    colormap('turbo');
    c = colorbar();
    c.Label.String = 'Surface misfit (m)';
    
    caxis([-150 150])
    set(gca, 'YDir', 'normal');
    xticks(1:3:length(cryosat_data.times));
    xticklabels(month_names(1:3:end));
    yticks(1:10:length(x_flowline));
    yticklabels(round(distance(1:10:end), 1));
    xlabel('Month');
    ylabel('Distance along flowline (km)');

    subplot(2,1,2)
    imagesc(log10(abs(interp_data) + 1));
    title('log10(abs(misfit) + 1)')
    colormap('turbo');
    c = colorbar();
    c.Label.String = "log10(Surface misfit) (m)";

    set(gca, 'YDir', 'normal');
    xticks(1:length(cryosat_data.times));
    xticklabels(month_names);
    yticks(1:10:length(x_flowline));
    yticklabels(round(distance(1:10:end), 1));
    xlabel('Month');
    ylabel('Distance along flowline (km)');
    if save_figures
        exportgraphics(gcf, sprintf("Figure/flowline_elevation_misfit_monthly_%s.png", id), 'Resolution', 300);
    end 

    %% compute transient velocity misfit movie
    if movie
        movie_vel_transient_error(md, transient_errors, cryosat_data.times, ice_masks<0, ' Elevation misfit monthly', [-150, 150], []);
    end


%% ------------ PER YEAR ANALYSIS ELEVATION ---------------
    % ---------- compute transient velocity misfit along flowline -------------
    %%% PLOTTING IDEAS: 
    %%% 1) plot each flowline as row of pixels, with time on x-axis and distance on y-axis, colorbar for misfit
    %%% 2) plot each flowline on regular plot, and select gradient colorbar
    x_flowline = fl.flowlineList{1}.x;
    y_flowline = fl.flowlineList{1}.y;
    cryosat_data = load("/home/eyhli/IceModeling/work/lia_kq/Data/validation/cryosat/cryosat_onmesh.mat");
    elev_data = cryosat_data.interpolated_surface - geoid;
    years = 2010:2021;
    [transient_errors, ice_masks] = get_transient_vel_errors(elev_model, elev_data, t_model, years, [], ice_levelset, 'yearly');
    interp_data = zeros(length(x_flowline), length(years));
    % yearly_error_vector = [];
    % grouping_vector = [];
    find_years = floor(t_model);
    yearly_avg_vector = zeros(1, length(years));
    yearly_med_vector = zeros(1, length(years));
    yearly_std_vector = zeros(1, length(years));
    coverage = zeros(1, length(years));

    for i=1:length(years)
        interp_data(:, i) = interpToFlowline(md.mesh.x, md.mesh.y, transient_errors(:, i), x_flowline, y_flowline);
        error = transient_errors(:, i);
        ice_mask_for_year = logical(sum(ice_levelset(:, find_years==i)>0,2, 'omitnan'));
        error(ice_mask_for_year) = nan;
        yearly_avg_vector(i) = mean(error, 'omitnan');
        yearly_med_vector(i) = median(error, 'omitnan');
        yearly_std_vector(i) = std(error, 'omitnan');

        % domain area coverage
        [~, ~, areas_domain, areas_masked] = get_data_on_elements(md, error, ~domain_mask);
        coverage(i) = 100 * round(sum(areas_masked, 'omitnan') / sum(areas_domain, 'omitnan'), 2);
        % [~, error, ~] = integrateOverDomain(md, error, ice_mask_for_year);
        % yearly_error_vector = [yearly_error_vector; error'];
        % yearly_name_vector = repmat(years(i), length(yearly_error_vector), 1);
        % grouping_vector = [grouping_vector; yearly_name_vector];
    end
    coverage = num2cell(coverage);
    for i=1:length(coverage)
        coverage{i} = append(num2str(coverage{i}), ' %');
    end
    
    % boxplot
    figure(348)
    errorbar(years, yearly_avg_vector, yearly_std_vector, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize',10)
    hold on;
    scatter(years, yearly_med_vector, 'rx');
    text(years, yearly_avg_vector - yearly_std_vector - 20, coverage, 'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', 10);
    legend('Mean +/- std. dev.', 'Median')
    grid on
    % boxplot(yearly_error_vector, grouping_vector)
    % X = [yearly_error_vector(:), grouping_vector];
    % hist3(X, 'Edges', {-100:1:100, (1985:1:2018)}, 'CDataMode', 'auto')
    % h = histogram2(yearly_error_vector(:), grouping_vector, -1000:10:1000, (1985:1:2018), 'DisplayStyle', 'tile','Normalization','probability', 'ShowEmptyBins','on')
    % yticklabels(1985:1:2018)
    ylabel('Mean Error')
    xlabel('time')
    xlim([2009, 2022])
    title('Summary statistics of surface elevation error per year (2010-2021)')
    subtitle('Percentage of valid area in fast flow domain shown below error bars')
    hold off
    if save_figures
        exportgraphics(gcf, sprintf("Figure/summary_stats_elevation_misfit_yearly_%s.png", id), 'Resolution', 300);
    end

    % filter nans
    first_data_row = zeros(50, length(years));
    last_data_row = zeros(1, length(years));
    buffer = 3; 

    for i=1:length(years)
        not_nan = ~isnan(interp_data(:, i));
        first_data_row(:, i) = find(not_nan, 50, 'first');
        last_data_row(i) = find(not_nan, 1, 'last') - buffer; % 
        interp_data(last_data_row:end, i) = nan;
    end
    interp_data = interp_data(max(first_data_row):max(last_data_row) - buffer, :);
    x_flowline = x_flowline(max(first_data_row):max(last_data_row) - buffer);
    y_flowline = y_flowline(max(first_data_row):max(last_data_row) - buffer);
    distance = cumsum([0; sqrt((x_flowline(2:end) - x_flowline(1:end-1)) .^ 2 + (y_flowline(2:end) - y_flowline(1:end-1)) .^ 2)]') / 1000;
    distance  = abs(max(distance) - distance);

    figure(329);
    subplot(2,1,1)
    imagesc(interp_data);
    title('Flowline misfit yearly average 2010-2021')
    colormap('turbo');
    c = colorbar();
    c.Label.String = 'Surface elevation misfit (m)';

    caxis([-200 200])
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
    c.Label.String = "log10(Surface elevation misfit) (m)";

    set(gca, 'YDir', 'normal');
    xticks(1:length(years));
    xticklabels(years);
    yticks(1:10:length(x_flowline));
    yticklabels(round(distance(1:10:end), 1));
    xlabel('Year');
    ylabel('Distance along flowline (km)');
    if save_figures
        exportgraphics(gcf, sprintf("Figure/flowline_elevation_misfit_yearly_%s.png", id), 'Resolution', 300);
    end

    % for i=1:length(years)
    %     iclvl = logical(sum(ice_levelset(:, round(t_model) == years(i)) < 0, 2));
    %     plotmodel(md, 'data', transient_errors(:, i), 'axis', axes, 'mask', iclvl, 'title', num2str(years(i)), 'caxis', [-1000, 1000]); 
    %     hold on; plot(x_flowline, y_flowline, 'x-')
    %     % exportgraphics(gcf, ['/home/eyhli/IceModeling/work/lia_kq/vel_obs_' num2str(years(i)) '.png'])
    %     % pause
    % end
%% compute transient velocity misfit movie
if movie
    movie_vel_transient_error(md, transient_errors, years, ice_masks<0, ' Elevation misfit yearly', [-150, 150], []);
end

end