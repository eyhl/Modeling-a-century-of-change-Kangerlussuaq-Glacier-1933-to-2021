function [] = validate_model(results_folder_name, axes, md)
    if nargin < 2
        axes = 1.0e+06 .* [0.4167    0.4923   -2.2961   -2.2039];
        if nargin < 3
            model_file = dir(fullfile(results_folder_name, '*transient.mat'));
            model_file = fullfile(model_file.folder, model_file.name);
            md = loadmodel(model_file);
        end
    end
    find_config_path = dir(fullfile(results_folder_name, '*.csv'));
    config = readtable(fullfile(find_config_path.folder, find_config_path.name), "TextType", "string");

    if isnan(md.inversion.thickness_obs)
        param_models = dir(fullfile('Models/AGU', '*param.mat'));
        param_models = param_models(end); % in case there are more param files
        md_tmp = loadmodel(fullfile(param_models.folder, param_models.name));
        md.inversion.thickness_obs = md_tmp.geometry.thickness;
    end

    if isfield(md.results.TransientSolution, 'MaskIceLevelset')
        masked_values = md.results.TransientSolution(end).MaskIceLevelset<0;
    else
        masked_values = md.mask.ice_levelset < 0;
    end


    %% ---------------------------------------------- SPATIAL MISFIT ----------------------------------------------
    %% Thickness
    disp('Plotting ice thickness...')
    misfit_thickness = md.results.TransientSolution(end).Thickness - md.inversion.thickness_obs;

    % Misfit thickness caxis
    plotmodel(md, 'data', misfit_thickness, ...
                'caxis#all', [-2e2 2e2], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'axis#all', axes, 'figure', 89); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]); exportgraphics(gcf, fullfile(results_folder_name, 'H_misfit_limited.png'), 'Resolution', 300)

    % Misfit thickness
    plotmodel(md, 'data', misfit_thickness, ...
                'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 90); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]); exportgraphics(gcf, fullfile(results_folder_name, 'H_misfit.png'), 'Resolution', 300)

    figure(91);
    histogram(misfit_thickness(masked_values), 200, 'Normalization','pdf')
    title('Thickness misfit distribution')
    ylabel('Normalised pdf estimate')
    xlabel('Error [m]')
    set(gcf,'Position',[100 100 1500 1500])
    exportgraphics(gcf, fullfile(results_folder_name, 'thickess_misfit_hist.png'), 'Resolution', 300)


    %% Velocity
    % Velocity full domain
    disp('Plotting velocity...')
    velocity_pred = cell2mat({md.results.TransientSolution(end).Vel});
    plotmodel(md, 'data', velocity_pred, ...
                'caxis#all', [0 1.2e4], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 92); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_limited.png'), 'Resolution', 300)

    % Velocity axes domain, log scale
    plotmodel(md, 'data', velocity_pred, ...
                'caxis#all', [1 1.2e4], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'log', 10, ...
                'axis#all', axes, 'figure', 93); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_limited_log.png'), 'Resolution', 300)

    % Velocity misfit caxes
    misfit_velocity = velocity_pred - md.inversion.vel_obs;
    plotmodel(md, 'data', misfit_velocity, ...
                'caxis#all', [-2e2 2e2], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'axis#all', axes, 'figure', 94); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_limited.png'), 'Resolution', 300)

    % Velocity misfit
    plotmodel(md, 'data', misfit_velocity, ...
                'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 95); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit.png'), 'Resolution', 300)
    
    figure(96);
    histogram(misfit_velocity(masked_values), 200, 'Normalization','pdf')
    title('Velocity misfit distribution')
    ylabel('Normalised pdf estimate')
    xlabel('Error [m/yr]'); 
    set(gcf,'Position',[100 100 1500 1500]);
    exportgraphics(gcf, fullfile(results_folder_name, 'vel_misfit_hist.png'), 'Resolution', 300)

    %% ---------------------------------------------- TEMPORAL MISFIT ----------------------------------------------
    % Mass loss curve
    disp('Plotting mass balance...')
    mass_balance_curve_struct = mass_loss_curves([md], [], [config.friction_law], results_folder_name);
    save(fullfile(results_folder_name, 'mass_balance_curve_struct.mat'), 'mass_balance_curve_struct');

    % TODO: Add mass loss from other studies
    % ...
    
    %% ---------------------------------------------- Metrics ----------------------------------------------
    disp('Computing metrics...')
    [~, mean_misfit_thickness, ~] = integrateOverDomain(md, misfit_thickness, ~masked_values); % avg misfit per area [m]
    [~, mean_misfit_velocity, ~] = integrateOverDomain(md, misfit_velocity, ~masked_values); % avg misfit per area [m/yr]

    % Write to table
    Metric = {'Domain avg. H error';'Domain avg. vel error'};
    Values = [mean_misfit_thickness; mean_misfit_velocity];

    T = table(Values, 'RowNames', Metric);
    writetable(T, fullfile(results_folder_name, 'metrics.dat'), 'WriteRowNames', true) 


    %% Video
    disp('Making video...')
    movie_vel(md, fullfile(results_folder_name, 'velocity_movie'))

    % % load bedmachine mask and time steps
    % mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
    % times = [md.results.TransientSolution.time];
    
    % %% THICKNESS
    % % interpolate 2021 surface
    % surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
    % surface(isnan(surface)) = md.geometry.surface(isnan(surface)); % add 2007 surface to NaN in borders

    % % compute 2021 thickness
    % obs_thickness = surface - md.geometry.bed;

    % % extract predicted thickness
    % index_2021 = find(times > 2020 & times < 2022);
    % pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');
    % misfit_thickness = pred_thickness - obs_thickness;

    % %% VELOCITY
    % index_MEaSURE = find(times > 1995 & times < 2015);
    % data_vx = '/data/eigil/work/lia_kq/Data/measure_multi_year_v1/greenland_vel_mosaic250_vx_v1.tif'; 
    % data_vy = '/data/eigil/work/lia_kq/Data/measure_multi_year_v1/greenland_vel_mosaic250_vy_v1.tif';
    % [obs_velocity, ~, ~] = interpVelocity(md, data_vx, data_vy);
    % pred_velocity = mean([md.results.TransientSolution(index_MEaSURE).Vel], 2, 'omitnan');
    % misfit_velocity = pred_velocity - obs_velocity;

    % base rmse computation on relevant areas
    % misfit_thickness(md.mask.ice_levelset == 1) = NaN; % ocean
    % misfit_thickness(mask == 1) = NaN; % non-ice areas
    % misfit_velocity(md.mask.ice_levelset == 1) = NaN;
    % misfit_velocity(mask == 1) = NaN;

    % rmse_thickness = sqrt(mean((misfit_thickness) .^ 2, 'omitnan'));
    % rmse_velocity = sqrt(mean((misfit_velocity) .^ 2, 'omitnan'));

    % % remove nans and replace with 0, i.e. no misfit
    % misfit_thickness(isnan(misfit_thickness)) = 0;
    % misfit_velocity(isnan(misfit_thickness)) = 0;
end