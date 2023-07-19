function [md, mae_list, misfit_thickness_list, mean_thickness_list] = modulate_initial_thickness5(md, step_size, n, smoothing_factor)
    error_cap = 50;
    min_thickness = 10;

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

    % initialise arrays for saving iteration history
    mae_list = zeros(n+1, 1);
    mean_thickness_list = zeros(n, 1);
    step_size_history = zeros(n, 1);
    misfit_thickness_list = zeros(length(md.geometry.surface), n+1);
    updated_thickness = zeros(length(md.geometry.surface), n+1);

    % set intial mae misfit
    mae_list(1) = inf;
    updated_thickness(:, 1) = md.geometry.thickness;

    % load observed thickness in 2021 from Ice Sat 2
    obs_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
    obs_thickness = obs_surface - md.geometry.base;

    % ocean + some spots on the cliffs which are not a part of the glacier
    front_area_small = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/fast_flow/dont_update_init_H_here_small.exp', 2));
    front_area_large = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/fast_flow/dont_update_init_H_here_large.exp', 2));
    area_of_no_error = ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/modulation/area_of_missing_error_1900.exp', 2);
    

    fid = fopen('status.txt','w');
    j = 1;
    for i = 2:n+1
        if i-1 ~= 1
            disp('SOLVE')
            md = solve(md,'Transient','runtimename',false); 
            fprintf("SAVE at iteration %d\n", i-1);
            save(sprintf("/home/eyhli/IceModeling/work/lia_kq/Models/budd_dec9_bedc_%d.mat", i-1) , 'md', '-v7.3');
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
        misfit_thickness(misfit_thickness<-error_cap) = -error_cap;
        misfit_thickness(misfit_thickness>=error_cap) = error_cap;
        
        % misfit_thickness(final_levelset > 0) = NaN; % ocean
        misfit_thickness(front_area_small) = NaN; % ocean / irrelavant front area, cannot be updated
        % misfit_thickness(mask == 1) = NaN; % non-ice areas

        % compute mean abs error
        mae_thickness = mean(abs(misfit_thickness), 'omitnan');

        % remove NaNs, insert 0 misfit
        misfit_thickness(isnan(misfit_thickness)) = 0;

        % save for statistics and monitoring
        mae_list(i) = mae_thickness;
        misfit_thickness_list(:, i-1) = misfit_thickness;
        mean_thickness_list(i-1) = mean(pred_thickness, 1);

        % update initial guess
        dH = zeros(size(pred_thickness));
        nodes_with_large_err = abs(misfit_thickness) >= 10;
        dH(nodes_with_large_err) = misfit_thickness(nodes_with_large_err);

        % propagate positions back in time 
        [x_back, y_back, temporal_avg_field, ~] = flowline_traceback(md, dH, true);
        
        plotmodel(md, 'data', temporal_avg_field, 'figure', 500, 'title', 'update', 'caxis', [-300, 300]); ; exportgraphics(gcf, sprintf("temporal_avg_field%d.png", i-1));

        % remove area with points that end up in the water.
        dH = temporal_avg_field;
        dH(front_area_small) = 0;

        % % smooth update
        % dH = averaging(md, dH, smooth);

        % decrease the step size if you overshoot
        if mae_thickness >= mae_list(i-1) % increasing
            step_size = 0.9 * step_size;
        end
        step_size_history(i) = step_size;

        updated_thickness(:, i) = updated_thickness(:, i-1) - step_size .* dH;

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
        fprintf(fid, '%d  %f  %f  %f  %s\n', i-1, mae_thickness, mean_thickness_list(i-1), step_size, datetime);

        % for saving the variables
        thickness = md.geometry.thickness;
        surface = md.geometry.surface;
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/misfit_thickness%d.mat", i-1) , 'misfit_thickness', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/dH%d.mat", i-1) , 'dH', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/md.geometry.thickness%d.mat", i-1) , 'thickness', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/md.geometry.surface%d.mat", i-1) , 'surface', '-v7.3');
    end
end