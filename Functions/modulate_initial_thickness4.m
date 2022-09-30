function [md, mae_list, misfit_thk, mean_thicknesses, adam_steps] = modulate_initial_thickness4(md, step_size, n, smoothing_factor)
    %% Trying a constant correction term of -200 m, then sensitivity analysis with varying factors. 
    % For this reason I have removed the Adam step. Factors are implemented through the step_size

    if nargin < 5
        smoothing_factor = 1;
        stop_adam_updates = Inf;
    end

    if ~exist('md','var')
        disp("Loading model from default Models/ folder")
        md = loadmodel('Models/Model_kangerlussuaq_transient.mat');
    elseif isstring(md)
        if strcmp(md, "init")
            disp('Starting a new model')
            config_name = "config-init.csv";
            md = run_model(config_name);
        end
        sprintf("Loading model from path: %s", md)
        md = loadmodel(md);
    end

    
    if length(smoothing_factor) > 1
        smoothing_factor_schedule = true;
        smooth = smoothing_factor(1);
    else
        smoothing_factor_schedule = false;
        smooth = smoothing_factor(1);
    end

    if length(step_size) < 1
        step_size = [step_size(1)];
    end


    config_name = "config-modulation.csv";

    rng(3)
    % factor for average gradient
    beta_1 = 0.900;
    % factor for average squared gradient
    beta_2 = 0.999;

    mae_list = zeros(n+1, 1);
    adam_steps = zeros(n+1, 1);
    mean_thicknesses = zeros(n, 1);

    % set intial mae misfit and adam step
    mae_list(1) = inf; adam_steps(1) = NaN;

    m = zeros(length(md.geometry.surface), n+1);
    v = zeros(length(md.geometry.surface), n+1);

    misfit_thk = zeros(length(md.geometry.surface), n+1);
    obs_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
    obs_thickness = obs_surface - md.geometry.base;

    initial_levelset = md.levelset.spclevelset(1:end-1, 1);
    final_levelset = md.levelset.spclevelset(1:end-1, end);
    mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
    % ocean + some spots on the cliffs which are not a part of the glacier
    front_area_small = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_small.exp', 2));
    front_area_large = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_large.exp', 2));

    updated_thickness = zeros(length(md.geometry.surface), n+1);
    updated_thickness(:, 1) = md.geometry.thickness;

    fid = fopen('status.txt','w');
    j = 1;
    for i = 2:n+1
        if i-1 ~= 1
            disp('SOLVE')
            md = solve(md,'Transient','runtimename',false); 
            fprintf("SAVE at iteration %d\n", i-1);
            save("/data/eigil/work/lia_kq/Models/sensitivity.mat" , 'md', '-v7.3');
        end
        if smoothing_factor_schedule
            if rem(i-1, round(n/length(smoothing_factor))) == 0
                if i < n+1 % might break at last iteration otherwise
                    j = j + 1; 
                    smooth = smoothing_factor(j);
                end
            end
        end
        times = [md.results.TransientSolution.time];
        index_2021 = find(times > 2020 & times < 2022);

        pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

        % compute misfit and MAE
        misfit_thickness = pred_thickness - obs_thickness; 

        % base mae computation on relevant areas
        misfit_thickness(misfit_thickness<-200) = -200;
        misfit_thickness(misfit_thickness>=200) = 200;
        
        % misfit_thickness(final_levelset > 0) = NaN; % ocean
        misfit_thickness(front_area_small) = NaN; % ocean / irrelavant front area, cannot be updated
        % misfit_thickness(mask == 1) = NaN; % non-ice areas

        % compute mean abs error
        mae_thickness = mean(abs(misfit_thickness), 'omitnan');

        % remove NaNs, insert 0 misfit
        misfit_thickness(isnan(misfit_thickness)) = 0;

        % save for statistics and monitoring
        mae_list(i) = mae_thickness;
        misfit_thk(:, i-1) = misfit_thickness;
        mean_thicknesses(i-1) = mean(pred_thickness, 1);

        % update initial guess
        dH = zeros(size(pred_thickness));
        nodes_with_large_err = abs(misfit_thickness) >= 10;
        dH(nodes_with_large_err) = misfit_thickness(nodes_with_large_err);

        % propagate positions back in time 
        [x_back, y_back] = flowline_traceback(md, false);

        % remove area with points that end up in the water.
        dH(front_area_large) = NaN;
        dH(isnan(dH)) = 0;

        % interpolate to relevant 1900 points
        F = scatteredInterpolant(x_back(:, end), y_back(:, end), dH, 'nearest', 'nearest');
        dH = F(md.mesh.x, md.mesh.y);

        % smooth update
        dH = averaging(md, dH, smooth);
        updated_thickness(:, i) = updated_thickness(:, i-1) - step_size(i-1) .* dH;

        % update initial thickness
        md.geometry.thickness = updated_thickness(:, i);

        % ensure minimum thickness
        pos = find(md.geometry.thickness <= 10);
        md.geometry.thickness(pos) = 10;
        md.geometry.surface = md.geometry.thickness + md.geometry.base;

        pos = find(md.geometry.thickness <= 10);
        md.geometry.surface(pos) = md.geometry.base(pos) + 10; % Minimum thickness
        md.geometry.thickness = md.geometry.surface - md.geometry.base; % thickness=surface-base

        % update transient boundary spc thickness
        pos = find(md.mesh.vertexonboundary);
        md.masstransport.spcthickness(pos, 1) = md.geometry.thickness(pos);

        % status plotting
        plotmodel(md, 'data', md.geometry.surface, 'figure', 53, 'title', 'current surface'); exportgraphics(gcf, sprintf("currentSurf%d.png", i-1));
        plotmodel(md, 'data', misfit_thickness, 'figure', 48, 'title', 'misfit', 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("misfit%d.png", i-1));
        plotmodel(md, 'data', dH, 'figure', 50, 'title', 'update', 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("update%d.png", i-1));
        plotmodel(md, 'data', updated_thickness(:, i) - updated_thickness(:, i-1), 'figure', 51, 'title', 'difference between thickness i and i-1'); exportgraphics(gcf, sprintf("difference%d.png", i-1));
        plotmodel(md, 'data', updated_thickness(:, i), 'figure', 52, 'title', 'current thickness', 'caxis', [0, 2500]); exportgraphics(gcf, sprintf("currentH%d.png", i-1));
        fprintf(fid, '%d  %f  %f  %f  %s\n', i-1, mae_thickness, mean_thicknesses(i-1), step_size(i-1), datetime);

        % for saving the variables
        thickness = md.geometry.thickness;
        surface = md.geometry.surface;
        save(sprintf("/data/eigil/work/lia_kq/misfit_thickness%d.mat", i-1) , 'misfit_thickness', '-v7.3');
        save(sprintf("/data/eigil/work/lia_kq/dH%d.mat", i-1) , 'dH', '-v7.3');
        save(sprintf("/data/eigil/work/lia_kq/md.geometry.thickness%d.mat", i-1) , 'thickness', '-v7.3');
        save(sprintf("/data/eigil/work/lia_kq/md.geometry.surface%d.mat", i-1) , 'surface', '-v7.3');
    end
end