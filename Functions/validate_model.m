function [] = validate_model(results_folder_name, axs, md)
    if nargin < 2
        axs = 1.0e+06 .* [0.4167    0.4923   -2.2961   -2.2039];
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
    %% ------------------------------------------------- THICKNESS ------------------------------------------------
    times = cell2mat({md.results.TransientSolution.time});
    index_1995_2015 = 1995 < times & times < 2015;
    
    %% Thickness
    disp('Plotting ice thickness...')
    average_thickness = mean(cell2mat({md.results.TransientSolution(:, index_1995_2015).Thickness}),2);
    misfit_thickness = average_thickness - md.inversion.thickness_obs;

    % Misfit thickness caxis
    plotmodel(md, 'data', misfit_thickness, ...
                'caxis#all', [-2e2 2e2], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'axis#all', axs, 'figure', 89); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                h = colorbar();
                title(h, '[m]'); 
    exportgraphics(gcf, fullfile(results_folder_name, 'H_misfit_limited.png'), 'Resolution', 300)

    % Misfit thickness
    plotmodel(md, 'data', misfit_thickness, ...
                'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 90); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                h = colorbar();
                title(h, '[m]') 
    exportgraphics(gcf, fullfile(results_folder_name, 'H_misfit.png'), 'Resolution', 300)

    figure(91);
    histogram(misfit_thickness(masked_values), 200, 'Normalization','pdf')
    title('Thickness misfit distribution')
    ylabel('Normalised pdf estimate')
    xlabel('Error [m]')
    set(gcf,'Position',[100 100 1500 1500])
    exportgraphics(gcf, fullfile(results_folder_name, 'thickess_misfit_hist.png'), 'Resolution', 300)

    icesat_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);
    index_2019 = 2019 < times & times <= 2021;
    final_surface = mean(cell2mat({md.results.TransientSolution(:, index_2019).Surface}), 2);
    icesat_misfit_surface = final_surface - icesat_surface;
    icesat_mask = ~isnan(icesat_misfit_surface) & masked_values;

    % Misfit thickness caxis
    plotmodel(md, 'data', icesat_misfit_surface, ...
                'caxis#all', [-1.5e2 1.5e2], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'axis#all', axs, 'figure', 89); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]); 
                h = colorbar();
                title(h, '[m]') 
                exportgraphics(gcf, fullfile(results_folder_name, 'S_misfit_limited_icesat.png'), 'Resolution', 300)

    % Misfit thickness
    plotmodel(md, 'data', icesat_misfit_surface, ...
                'caxis#all', [-1.5e2 1.5e2], ...
                'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 90); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]); 
                h = colorbar();
                title(h, '[m]') 
                exportgraphics(gcf, fullfile(results_folder_name, 'S_misfit_icesat.png'), 'Resolution', 300)

    figure(91);
    histogram(icesat_misfit_surface(masked_values), 200, 'Normalization','pdf')
    title('Thickness misfit distribution')
    ylabel('Normalised pdf estimate')
    xlabel('Error [m]')
    set(gcf,'Position',[100 100 1500 1500])
    exportgraphics(gcf, fullfile(results_folder_name, 'surface_misfit_hist_icesat.png'), 'Resolution', 300)

    %% ---------------------------------------------- VELOCITY ----------------------------------------------
    % Mean velocity full domain
    disp('Plotting velocity...') 

    % get average precidtion in 20 yr span to match how Measure vel is made.
    velocity_pred = cell2mat({md.results.TransientSolution(:).Vel});
    velocity_pred = velocity_pred(:, index_1995_2015);
    velocity_pred = mean(velocity_pred, 2);

    plotmodel(md, 'data', velocity_pred, ...
                'caxis#all', [0 1.2e4], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 92); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                h = colorbar();
                title(h, '[m/yr]') 
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_limited.png'), 'Resolution', 300)

    % Velocity axs domain, log scale
    plotmodel(md, 'data', velocity_pred, ...
                'caxis#all', [1 1.2e4], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'log', 10, ...
                'axis#all', axs, 'figure', 93); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                h = colorbar();
                title(h, '[m/yr]') 
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_limited_log.png'), 'Resolution', 300)

    % Velocity misfit caxs
    misfit_velocity = velocity_pred - md.inversion.vel_obs;
    plotmodel(md, 'data', misfit_velocity, ...
                'caxis#all', [-1e3 1e3], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'axis#all', axs, 'figure', 94); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                h = colorbar();
                title(h, '[m/yr]') 
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_limited.png'), 'Resolution', 300)

    % Velocity misfit
    plotmodel(md, 'data', misfit_velocity, ...
                'caxis#all', [-1e3 1e3], ...
                'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 95); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                h = colorbar();
                title(h, '[m/yr]') 
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit.png'), 'Resolution', 300)

    plotmodel(md, 'data', abs(misfit_velocity), ...
                'caxis#all', [1 1e3], ...
                'log', 10, ...
                'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 951); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                h = colorbar();
                title(h, '[m/yr]') 
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_log.png'), 'Resolution', 300)

    figure(96);
    histogram(misfit_velocity(masked_values), 200, 'Normalization','pdf')
    title('Velocity misfit distribution')
    ylabel('Normalised pdf estimate')
    xlabel('Error [m/yr]'); 
    set(gcf,'Position',[100 100 1500 1500]);
    exportgraphics(gcf, fullfile(results_folder_name, 'vel_misfit_hist.png'), 'Resolution', 300)

    % Final velocity misfit full domain
    % get average precidtion in 20 yr span to match how Measure vel is made.
    velocity_pred = cell2mat({md.results.TransientSolution(:).Vel});
    velocity_pred = velocity_pred(:, end);

    % Velocity misfit caxs
    misfit_velocity_final = velocity_pred - md.inversion.vel_obs;
    plotmodel(md, 'data', misfit_velocity_final, ...
                'caxis#all', [-5e2 5e2], 'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'axis#all', axs, 'figure', 94); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_limited_final.png'), 'Resolution', 300)

    % Velocity misfit
    plotmodel(md, 'data', misfit_velocity_final, ...
                'mask#all', masked_values, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'figure', 95); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
                exportgraphics(gcf, fullfile(results_folder_name, 'Vel_misfit_final.png'), 'Resolution', 300)

    figure(961);
    histogram(misfit_velocity_final(masked_values), 200, 'Normalization','pdf')
    title('Velocity misfit distribution')
    ylabel('Normalised pdf estimate')
    xlabel('Error [m/yr]'); 
    set(gcf,'Position',[100 100 1500 1500]);
    exportgraphics(gcf, fullfile(results_folder_name, 'vel_misfit_hist_final.png'), 'Resolution', 300)

    %% ---------------------------------------------- TEMPORAL MISFIT ----------------------------------------------
    % Mass loss curve
    disp('Plotting mass balance...')
    % mass_balance_curve_struct = mass_loss_curves([md], [], [config.friction_law], results_folder_name);
    [mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs([md], [], [config.friction_law], results_folder_name, true, false);
    save(fullfile(results_folder_name, 'mass_balance_curve_struct.mat'), 'mass_balance_curve_struct');

    % TODO: Add mass loss from other studies
    % ...
    
    %% ---------------------------------------------- Metrics ----------------------------------------------
    disp('Computing metrics...')
    [~, mean_misfit_thickness, ~] = integrateOverDomain(md, misfit_thickness, ~masked_values); % avg misfit per area [m]
    [~, icesat_misfit_surface, ~] = integrateOverDomain(md, icesat_misfit_surface, ~icesat_mask); % avg misfit per area [m]
    [~, mean_misfit_velocity, ~] = integrateOverDomain(md, misfit_velocity, ~masked_values); % avg misfit per area [m/yr]
    [~, final_misfit_velocity, ~] = integrateOverDomain(md, misfit_velocity_final, ~masked_values); % avg misfit per area [m/yr]

    % Write to table
    Metric = {'Domain avg. H error (1995-2015)'; 'Domain final H error (2021)'; 'Domain avg. vel error (1995-2015)'; 'Domain final vel error (2021)'};
    Values = [mean_misfit_thickness; icesat_misfit_surface; mean_misfit_velocity; final_misfit_velocity];

    T = table(Values, 'RowNames', Metric);
    writetable(T, fullfile(results_folder_name, 'metrics.dat'), 'WriteRowNames', true) 

    figure2alt;
    close all
    figure2c;
    close all

    % % Compute present day misfit
    % quantify_field_difference(md, md.initialization.vel, md.inversion.vel_obs, append(results_folder_name, '/present_VEL_misfit'), true, true, axs);

    % % final_surface_tmp = final_surface;
    % % icesat_surface_tmp = icesat_surface;
    % % final_surface_tmp(isnan(icesat_surface)) = NaN;
    % % quantify_field_difference(md, final_surface, icesat_surface, append(results_folder_name, '/present_SURFACE_misfit'), true, true, axs);

    % %% Compare to budd solution
    % md_budd = loadmodel('Models/KG_budd_lia.mat');
    % % Compute present day misfit
    % quantify_field_difference(md, md.initialization.vel, md_budd.initialization.vel, append(results_folder_name, '/present_INIT_VEL_diff'), false, true, axs);

    % model_init_diff =  md.initialization.vel - md_budd.initialization.vel;
    
    % plotmodel(md, 'data', model_init_diff, ...
    %         'caxis#all', [-2e2 2e2], 'mask#all', masked_values, ...
    %         'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
    %         'axis#all', axs, 'figure', 94); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
    %         exportgraphics(gcf, append(results_folder_name, '/LIA_init_diff.png'), 'Resolution', 300)

    % % Compute LIA comparison Budd to other solutions
    % quantify_field_difference(md, md.results.StressbalanceSolution.Vel, md_budd.results.StressbalanceSolution.Vel, append(results_folder_name, '/LIA_VEL_diff'), true, true, axs);

    % % Velocity misfit caxs
    % LIA_init_diff = md.results.StressbalanceSolution.Vel - md_budd.results.StressbalanceSolution.Vel;

    % plotmodel(md, 'data', LIA_init_diff, ...
    %         'caxis#all', [-2e2 2e2], ...
    %         'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
    %         'axis#all', axs, 'figure', 94); colormap('turbo'); set(gcf,'Position',[100 100 1500 1500]);
    %         exportgraphics(gcf, append(results_folder_name, '/LIA_init_diff.png'), 'Resolution', 300)

    %% Video
    disp('Making video...')
    movie_vel(md, fullfile(results_folder_name, 'velocity_movie'))
    movie_thk(md, fullfile(results_folder_name, 'thinning_movie'))
    movie_dH_accu(md, fullfile(results_folder_name, 'dH_accumulated'))
end