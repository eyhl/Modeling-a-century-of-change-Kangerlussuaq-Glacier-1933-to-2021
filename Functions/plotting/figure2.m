save_figures = false;
axes = [416700,      498000,    -2299100,    -2203900];

% md = loadmodel("/data/eigil/work/lia_kq/Results/budd_default-22-May-2023/KG_transient.mat");
mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
its_live_yearly = load('/data/eigil/work/lia_kq/Data/validation/velocity/its_live_onmesh.mat');
fl = load('/data/eigil/work/lia_kq/Data/validation/flowline_positions/central_flowline.mat', 'flowlineList');
x_flowline = fl.flowlineList{1}.x;
y_flowline = fl.flowlineList{1}.y;
domain_path = 'Exp/fast_flow/valid_elements_in_fast_flow.exp';
domain_mask = ContourToNodes(md.mesh.x, md.mesh.y, domain_path, 2);

t_model = [md.results.TransientSolution.time];
vel_model = [md.results.TransientSolution.Vel];
ice_mask = [md.results.TransientSolution.MaskIceLevelset];

% axes = 1.0e+06 .* [0.4167    0.4923   -2.2961   -2.2039];

% plotmodel(mdb, 'data', (vel2017 - interp_vel(:, end-1)) ./ (interp_vel(:, end-1)) .* 100, 'caxis', [-50, 50], 'axis', axes)                                
% xlabel('X')
% ylabel('Y')
% set(gca,'fontsize', 14)
% h = colorbar;
% title(h, "[%]")

% FLOWLINE ANALYSIS
vel_data = its_live_yearly.interp_vel;
years = 1985:2018;
[transient_errors, ice_masks] = get_transient_vel_errors(vel_model, vel_data, t_model, years, [], ice_mask, 'yearly');
interp_data = zeros(length(x_flowline), length(years));
find_years = floor(t_model);
yearly_avg_vector = zeros(1, length(years));
yearly_med_vector = zeros(1, length(years));
yearly_std_vector = zeros(1, length(years));
coverage = zeros(1, length(years));

for i=1:length(years)
    error = transient_errors(:, i);
    % plotmodel(md, 'data', error, 'caxis', [-1000, 1000], 'axis', axes, 'figure', 1)

    % ice_levelset_for_year = ice_mask(:, find_years==2007);
    % ice_nodes = sum(ice_mask(:, find_years==2007)>0, 1);
    % [~, most_retreated_index] = min(ice_nodes);
    % ice_mask_for_year = logical(ice_levelset_for_year(:, most_retreated_index)>0);

    error(~mask) = nan;
    % plotmodel(md, 'data', error, 'caxis', [-1000, 1000], 'axis', axes, 'figure', 2)
    % pause
    interp_data(:, i) = interpToFlowline(md.mesh.x, md.mesh.y, error, x_flowline, y_flowline);

    yearly_avg_vector(i) = mean(error, 'omitnan');
    yearly_med_vector(i) = median(error, 'omitnan');
    yearly_std_vector(i) = std(error, 'omitnan');

    % domain area coverage
    [~, ~, areas_domain, areas_masked] = get_data_on_elements(md, error, ~domain_mask);
    coverage(i) = 100 * round(sum(areas_masked, 'omitnan') / sum(areas_domain, 'omitnan'), 2);
    
end

coverage = num2cell(coverage);
for i=1:length(coverage)
    coverage{i} = append(num2str(coverage{i}), ' %');
end

% boxplot
% figure(344)
% errorbar(years, yearly_avg_vector, yearly_std_vector, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize',10)
% hold on;
% scatter(years, yearly_med_vector, 'rx');
% text(years, yearly_avg_vector - yearly_std_vector - 20, coverage, 'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', 10);
% legend('Mean +/- std. dev.', 'Median')
% grid on;
% ylabel('Mean Error')
% xlabel('time')
% xlim([1984, 2019])
% title('Summary statistics of velocity error per year (1985-2018)')
% subtitle('Percentage of valid area in fast flow domain shown below error bars')
% hold off

if save_figures
    exportgraphics(gcf, sprintf('Figure/summary_stats_velocity_misfit_yearly_%s.png', id), 'Resolution', 300);
end 

% filter nans
k = 1;
first_data_row = zeros(1, length(years)); 
last_data_row = zeros(1, length(years));
buffer = 0; 

for i=1:length(years)
    not_nan = ~isnan(interp_data(:, i));
    first_data_row(:, i) = find(not_nan, 1, 'first');
    last_data_row(i) = find(not_nan, 1, 'last') - buffer; % 
    interp_data(last_data_row:end, i) = nan;
end
interp_data = interp_data(max(first_data_row):max(last_data_row) - buffer, :);
x_flowline = x_flowline(max(first_data_row):max(last_data_row) - buffer);
y_flowline = y_flowline(max(first_data_row):max(last_data_row) - buffer);
distance = cumsum([0; sqrt((x_flowline(2:end) - x_flowline(1:end-1)) .^ 2 + (y_flowline(2:end) - y_flowline(1:end-1)) .^ 2)]') / 1000;
distance  = abs(max(distance) - distance);



ice_mask2017 = ice_mask(:, floor(t_model) == 2017);                                                         

plotmodel(mdb, 'data', vel2017 - interp_vel(:, end-1), 'mask', ice_mask2017(:, end)<0, 'caxis', [-1000, 1000], 'axis', axes, 'xticklabel#all', ' ', 'yticklabel#all', ' ', 'figure', 10, 'colorbar', 'off', ...
    'xtick', [], 'ytick', []) %  'expdisp', '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp'
colormap('turbo');
c = colorbar();
c.Label.String = 'Velocity misfit [m/yr]';
set(gcf,'Position',[100 100 1500 1500]); 

xlabel('X')
ylabel('Y')
% set(gca,'fontsize', 14)
% h = colorbar;
% title(h, '[m/yr]')
hold on;
plot(x_flowline, y_flowline, 'k')
% scatter(x_flowline(end-8), y_flowline(end-8), 'k', 'filled')  % THIS SHOW THE POINT WHERE THERE IS A CONSISTENT ERROR ACROSS ALL YEARS (START OF EXTRAPOLATION DOMAIN)
hold off


icesat_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);
index_2019 = 2019 < t_model & t_model <= 2021;
final_surface = mean(cell2mat({md.results.TransientSolution(:, index_2019).Surface}), 2);
icesat_misfit_surface = final_surface - icesat_surface;
icesat_mask = ~isnan(icesat_misfit_surface) & mask;

% Misfit thickness caxis
plotmodel(md, 'data', icesat_misfit_surface, ...
            'caxis#all', [-1.5e2 1.5e2], 'mask#all', icesat_mask, ...
            'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
            'axis', axes, 'figure', 89, 'colorbar', 'off', 'xtick', [], 'ytick', []); 
colormap('turbo'); 
set(gcf,'Position',[100 100 1500 1500]); 
c = colorbar();
c.Label.String = 'Surface elevation misfit [m]';
xlabel('X')
ylabel('Y')


figure(326);
s = pcolor(interp_data);
set(s, 'EdgeColor', 'none');
% set(s, 'EdgeColor', 'black', 'LineStyle', '-', 'LineWidth', 0.01);
% s.LineWidth = 0.01;

set(gca,'layer','top')

title('Flowline misfit yearly average 1985-2018')
colormap('turbo');
c = colorbar();
c.Label.String = 'Velocity misfit (m/yr)';

caxis([-2000 2000])
set(gca, 'YDir', 'normal');
xticks(0.5:length(years) - 0.5);
xticklabels(years);
yticks(1:10:length(x_flowline));
yticklabels(round(distance(1:10:end), 1));
xlabel('Year');
ylabel('Distance from 2007 front (km)');

% plotmodel(mdb, 'data', md.friction.coefficient, 'mask', ice_mask2017(:, end)<0, 'caxis', [0, 100], 'axis', axes, 'figure', 11, 'expdisp', '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp')
% xlabel('X')
% ylabel('Y')
% set(gca,'fontsize', 14)
% h = colorbar;
% title(h, '[m/yr]')
% hold on;
% plot(x_flowline, y_flowline, 'k-x')
% scatter(x_flowline(end-8), y_flowline(end-8), 'k', 'filled')