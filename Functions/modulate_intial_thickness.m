function [md, dh, misfit_thk, mean_thicknesses, step_size_history] = modulate_intial_thickness(md, step_size, n, spatial_smooth, smoothing_factor)
    save_path = "/data/eigil/work/lia_kq/Results";

    if nargin < 3
        spatial_smooth = true;

    end
    if nargin < 4
        spatial_smooth = true;
        smoothing_factor = 1;

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
    config_name = "config-modulation.csv";

    dh = zeros(n+1, 1);
    dh(1) = inf;
    step_size_history = zeros(n+1, 1);
    step_size_history(1) = step_size;
    mean_thicknesses = zeros(n+1, 1);
    misfit_thk = zeros(n+1, length(md.geometry.surface));

    obs_surface = interp2021Surface([md.mesh.x, md.mesh.y]);                             
    obs_thickness = obs_surface - md.geometry.base;
    initial_levelset = md.levelset.spclevelset(1:end-1, 1);
    final_levelset = md.levelset.spclevelset(1:end-1, end);
    initial_thickness = md.geometry.thickness;

    fid = fopen('status.txt','w');
    for i = 2:n+1
        if i-1 ~= 1
            disp('SOLVE')
            md = solve(md,'Transient','runtimename',false); 
            disp('SAVE')
            save("/data/eigil/work/lia_kq/Models/modulate_thickness.mat" , 'md', '-v7.3');
        end

        times = [md.results.TransientSolution.time];
        index_2021 = find(times > 2020 & times < 2022);

        if spatial_smooth
            % extract predicted thickness
            pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

            % interpolate onto coarse mesh
            pred_thickness = averaging(md, pred_thickness, smoothing_factor);
        else
            pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');
        end

        % compute misfit and MAE
        misfit_thickness = pred_thickness - obs_thickness; 

        % base mae computation on relevant areas
        misfit_thickness(final_levelset > 0) = NaN; % ocean
        % misfit_thickness(mask == 1) = NaN; % non-ice areas
        mae_thickness = mean(abs(misfit_thickness), 'omitnan');
        misfit_thickness(isnan(misfit_thickness)) = 0;

        % save for statistics and monitoring
        dh(i) = mae_thickness;
        misfit_thk(i-1, :) = misfit_thickness;
        mean_thicknesses(i-1) = mean(pred_thickness, 1);
        fprintf(fid, '%d    %f  %f  %f\n', i-1, mae_thickness, mean_thicknesses(i-1), step_size);

        if mae_thickness < dh(i-1) % decreasing
            step_size = min(1.25 * step_size, 1); % ensure maximum 1
        elseif mae_thickness >= dh(i-1) % increasing
            step_size = 1/2 * step_size;
        end
        step_size_history(i) = step_size;

        % update initial guess
        correction = zeros(size(pred_thickness));
        nodes_with_large_err = misfit_thickness >= 10;
        correction(nodes_with_large_err) = misfit_thickness(nodes_with_large_err);

        md.geometry.thickness = initial_thickness - step_size * correction;
        md.geometry.surface = md.geometry.thickness + md.geometry.base;

        % ensure minimum thickness
        pos = find(md.geometry.thickness <= 10);
        md.geometry.surface(pos) = md.geometry.base(pos) + 10; %Minimum thickness
        md.geometry.thickness = md.geometry.surface - md.geometry.base; % thickness=surface-base

        % update transient boundary spc thickness
        pos = find(md.mesh.vertexonboundary);
        md.masstransport.spcthickness(pos, 1) = md.geometry.thickness(pos);

    end
end