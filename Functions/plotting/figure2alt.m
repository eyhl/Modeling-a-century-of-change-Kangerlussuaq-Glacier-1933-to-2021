% axes = [416700,      498000,    -2299100,    -2203900];
axs = 1e6 .* [0.422302857764172   0.510073291293409  -2.303227021597650  -2.230919592486114];

if ~exist('results_folder_name')
    results_folder_name = './TmpRunBin';
end

mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
bed_rock_mask = mask == 1;
its_live_yearly = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/its_live_onmesh.mat');
fl = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/flowline_positions/central_flowline.mat', 'flowlineList');
x_flowline = fl.flowlineList{1}.x;
y_flowline = fl.flowlineList{1}.y;
domain_path = 'Exp/fast_flow/valid_elements_in_fast_flow.exp';
domain_mask = ContourToNodes(md.mesh.x, md.mesh.y, domain_path, 2);

t_model = [md.results.TransientSolution.time];
vel_model = [md.results.TransientSolution.Vel];
surf_model = [md.results.TransientSolution.Surface];

if isfield(md.results.TransientSolution, 'MaskIceLevelset')
    ice_mask = [md.results.TransientSolution(end).MaskIceLevelset];
else
    ice_mask = md.mask.ice_levelset < 0;
end

shape = shaperead('Exp/domain/plotting_present_domain.shp');
% [a, r] = readgeoraster('Data/validation/optical/greenland_mosaic_2019_KG.tiff');
raster = 'Data/validation/optical/greenland_mosaic_2019_KG.tiff';

gridsize = 50;

%% ----------- VEL ERROR -------------
f2 = figure(992);
hax2 = axes(f2);
t_start = 2007;
t_end = 2018;

data_times = 1985:1:2018;
index = find(floor(t_model) >= t_start & floor(t_model) < t_end);

velocity_model_avg = averageOverTime(vel_model, t_model, t_start, t_end);
velocity_obs_avg = mean(its_live_yearly.interp_vel(:, data_times >= t_start & data_times < t_end), 2);

field = velocity_model_avg - velocity_obs_avg;
field(ice_mask > 0 | bed_rock_mask, :) = NaN;
[~, vel_mean_error, ~] = integrateOverDomain(md, field, ice_mask>0 | bed_rock_mask); % avg misfit per area [m]
vel_std_error = std(field(:), 'omitnan');
vel_median_error = median(field(:), 'omitnan');
[field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape, gridsize, raster);

p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, field);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',0.8)
colormap(redgrayblue);
caxis([-1500 1500]);
c = colorbar();
c.Label.String = 'Surface velocity error [m/yr]';
c.Label.Position = [3.4, 0];
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
set(gcf,'Position',[100 100 580 450]); 
exportgraphics(gcf, fullfile(results_folder_name, 'itslive_vel_misfit_paper.png'), 'Resolution', 300)

plot(x_flowline(1:end-55), y_flowline(1:end-55), 'k--', 'LineWidth', 1.2);  % 55 found by trial and error

obj = scalebar(hax2); %default, recommanded

% ---Command support---
obj.Position = [430000, -2297000];              %X-Length, 15.
obj.XLen = 5000;              %X-Length, 15.
obj.YLen = 10000;              %X-Length, 15.
obj.XUnit = 'km';            %X-Unit, 'm'.
obj.YUnit = 'km';            %X-Unit, 'm'.
% obj.Position = [55, -0.6];  %move the whole SCALE position.
obj.hTextX_Pos = [1, -3.0e3]; %move only the LABEL position
obj.hTextY_Pos = [-3.0e3, 0.16]; %SCALE-Y-LABEL-POSITION
obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
obj.Color = 'k';             %'k'(default), 'w'
legend('', 'Flowline', '', '', '', '', 'Location', 'NorthWest')

% Write to table
Metric = {'vel_mean_error'; 'vel_median_error'; 'vel_std_error'};
Values = [vel_mean_error; vel_median_error; vel_std_error];

T = table(Values, 'RowNames', Metric);
writetable(T, fullfile(results_folder_name, 'its_live_error_metrics.dat'), 'WriteRowNames', true) 


%% ----------- THICKNESS ERROR -------------
f3 = figure(993);
hax3 = axes(f3);
t_start = 2019;
t_end = 2021;

icesat_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);
index = t_start <= t_model & t_model <= t_end;
surf_model_avg = mean(surf_model(:, index), 2);
field = surf_model_avg - icesat_surface;
field(ice_mask > 0 | bed_rock_mask, :) = NaN;
[vol, thickness_mean_error, ~] = integrateOverDomain(md, field, ice_mask>0 | bed_rock_mask); % avg misfit per area [m]
thickness_std_error = std(field(:), 'omitnan');
thickness_median_error = median(field(:), 'omitnan');
error_in_mass = vol  ./ (1e9) .* 0.9167; % Gt
full_field = field;

[field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape, gridsize, raster);

p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, field);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',0.8)
colormap(redgrayblue);
caxis([-150 150]);
c = colorbar();
c.Label.String = 'Ice thickness error [m]';
c.Label.Position = [3.4, 0];
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
set(gcf,'Position',[100 100 580 450]); 
exportgraphics(gcf, fullfile(results_folder_name, 'icesat_thickness_misfit_paper.png'), 'Resolution', 300)


% Write to table
Metric = {'thickness_mean_error'; 'thickness_median_error'; 'thickness_std_error'; 'error_in_mass'};
Values = [thickness_mean_error; thickness_median_error; thickness_std_error; error_in_mass];

T = table(Values, 'RowNames', Metric);
writetable(T, fullfile(results_folder_name, 'icesat_error_metrics.dat'), 'WriteRowNames', true) 