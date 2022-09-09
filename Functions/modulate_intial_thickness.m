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





























































    % %% OBSERVED THICKNESS
    % regular_mesh = [md.mesh.x, md.mesh.y];
    % obs_surface = interp2021Surface(regular_mesh);                             
    % mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));

    % % compute 2021 thickness
    % obs_thickness = obs_surface - md.geometry.bed;

    % % if spatial smoothing is enabled, get observations on coarse grid
    % if spatial_smooth
    %     % interpolate 2021 surface
    %     domain = ['Exp/' 'Kangerlussuaq_new' '.exp'];
    %     md = triangle(model, domain, 1500); % "model" is an empty md object
    %     coarse_mesh = [md.mesh.x, md.mesh.y];
    %     mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));

    %     % interpolate onto coarse mesh
    %     obs_surface = interp2021Surface(coarse_mesh);            
    %     obs_surface_2007 = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, md.geometry.surface, md.mesh.x, md.mesh.y);
    %     levelset_2019 = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, md.levelset.spclevelset(1:end-1, end), md.mesh.x, md.mesh.y);
    %     initial_levelset = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, md.levelset.spclevelset(1:end-1, 1), md.mesh.x, md.mesh.y);
    %     initial_thickness = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, md.geometry.thickness, md.mesh.x, md.mesh.y);

    %     obs_surface(isnan(obs_surface)) = obs_surface_2007(isnan(obs_surface)); % add 2007 surface to NaN in borders

    %     coarse_bed = interpBmGreenland(md.mesh.x, md.mesh.y, 'bed');
    %     coarse_base = coarse_bed; 
    %     % coarse_bed = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, md.geometry.bed, md.mesh.x, md.mesh.y);
    %     % coarse_base = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, md.geometry.base, md.mesh.x, md.mesh.y);

    %     obs_thickness = obs_surface - coarse_base;

    %     % set thickness and surface on ocean to 0
    %     obs_surface(levelset_2019 > 0) = 0; % this is in the ocean in 2019
    %     obs_thickness(levelset_2019 > 0) = 0; % this is in the ocean in 2019

    %     misfit_thk = zeros(n, length(initial_thickness));

    % end

    % times = [md.results.TransientSolution.time];
    % index_2021 = find(times > 2020 & times < 2022);

    % fid = fopen('status.txt','w');
    % for i = 1:n
    %     if i ~= 1
    %         disp('Interpolate update onto fine mesh')
    %         md.geometry.thickness = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, updated_thickness, md.mesh.x, md.mesh.y);
    %         md.geometry.surface = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, updated_surface, md.mesh.x, md.mesh.y);

    %         % ensure minimum thickness
    %         pos = find(md.geometry.thickness <= 10);
    %         md.geometry.surface(pos) = md.geometry.base(pos) + 10; %Minimum thickness
    %         md.geometry.thickness = md.geometry.surface - md.geometry.base; % thickness=surface-base
    %         plotmodel(md, 'data', md.geometry.thickness  <= 10 , 'figure', 1);


    %         % update transient boundary spc thickness
    %         pos = find(md.mesh.vertexonboundary);
    %         md.masstransport.spcthickness(pos, 1) = md.geometry.thickness(pos);


    %         % md.masstransport.spcthickness(1:end-1, 1) = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, spcthickness, md.mesh.x, md.mesh.y);
    %         % md.geometry.base = md.geometry.surface - md.geometry.thickness;
    %         % md.geometry.base = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, base, md.mesh.x, md.mesh.y);
    %         % md.geometry.bed = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, bed, md.mesh.x, md.mesh.y);

    %         % plotmodel(md, 'data', md.geometry.thickness, 'figure', 1);
    %         % plotmodel(md, 'data', md.geometry.surface - md.geometry.base, 'figure', 1);
    %         % plotmodel(md, 'data', md.geometry.thickness == (md.geometry.surface - md.geometry.base), 'figure', 3);

    %         disp('SOLVE')
    %         md = solve(md,'Transient','runtimename',false); %TODO: try to run this on its own, without updating thickness. Does the md.geom.thick change?
    %         disp('SAVE')
    %         save("/data/eigil/work/lia_kq/Models/modulate_thickness.mat" , 'md', '-v7.3');
    %     end

    %     if spatial_smooth
    %         % define bed
    %         bed = coarse_bed;
    %         base = coarse_base;
    %         spcthickness = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, md.masstransport.spcthickness(1:end-1, 1), md.mesh.x, md.mesh.y);
            
    %         % extract predicted thickness
    %         pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

    %         % interpolate onto coarse mesh
    %         pred_thickness = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, pred_thickness, md.mesh.x, md.mesh.y);
    %     else
    %         bed = md.geometry.bed;
    %         base = md.geometry.base;
    %         spcthickness = md.masstransport.spcthickness(1:end-1, 1);
    %         pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');
    %     end

    %     % compute misfit and MAE
    %     misfit_thickness = pred_thickness - obs_thickness; 
    %     % base mae computation on relevant areas
    %     misfit_thickness(initial_levelset > 0) = NaN; % ocean
    %     misfit_thickness(mask == 1) = NaN; % non-ice areas
    %     mae_thickness = mean(abs(misfit_thickness), 'omitnan');
    %     misfit_thickness(isnan(misfit_thickness)) = 0;

    %     % save for statistics and monitoring
    %     dh(i) = mae_thickness;
    %     misfit_thk(i, :) = misfit_thickness;
    %     mean_thicknesses(i) = mean(pred_thickness, 1);
    %     fprintf(fid, '%d    %f  %f\n', i, mae_thickness, mean_thicknesses(i));

    %     correction = zeros(size(pred_thickness));
    %     nodes_with_large_err = misfit_thickness >= 10;
    %     correction(nodes_with_large_err) = misfit_thickness(nodes_with_large_err);

    %     updated_thickness = initial_thickness - step_size * correction;
    %     updated_surface = updated_thickness + base;


    %     % plotmodel(md, 'data', updated_thickness, 'figure', 1);
    %     plotmodel(md, 'data', updated_surface-coarse_base, 'figure', 2);
    %     % plotmodel(md, 'data', updated_thickness == (updated_surface - coarse_base), 'figure', 3);
    %     % plotmodel(md, 'data', coarse_bed, 'figure', 4);


    %     % thickness=surface-base
    %     % TODO: UPDATE STEPSIZE
        
    % end

    % % % extract time steps
    % % times = [md.results.TransientSolution.time];


    % % % ITERATION 1
    % % [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md);
    % % mean_thicknesses(1) = mean(md.geometry.thickness); % 1062.7 
    % % dh(1) = rmse_thickness;
    % % dv(1) = rmse_velocity;

    % % fid = fopen('status.txt','w');
    % % for i = 2:n
    % %     %% 1) compute mae and misfit on coarser mesh
    % %     [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md);

    % %     %% 2) update on coarser mesh
    % %     md = update_thickness(md, misfit_thickness, 'global', 0.8); % tried 1/2, 2/3, 1

    % %     %% save statistics and development
    % %     mean_thicknesses(i) = mean(md.geometry.thickness); % 1062.7 
    % %     dh(i) = rmse_thickness;
    % %     dv(i) = rmse_velocity;
    % %     misfit_thk(i, :) = misfit_thickness;
    % %     misfit_vel(i, :) = misfit_velocity;

    % %     %% 3) interpolate onto fine mesh and solve
    % %     disp('SOLVE')
    % %     md = solve(md,'Transient','runtimename',false); %TODO: try to run this on its own, without updating thickness. Does the md.geom.thick change?
    % %     disp('SAVE')
    % %     save("/data/eigil/work/lia_kq/Models/modulate_thickness.mat" , 'md', '-v7.3');
    % %     fprintf(fid, '%d    %f  %f\n', i, rmse_thickness, mean_thicknesses(i));
    % % end
    % % fclose(fid);

    % % save("Results/misfit_thickness.mat", 'misfit_thk', '-v7.3');
    % % save("/data/eigil/work/lia_kq/Results/mean_thicknesses.mat" , 'mean_thicknesses', '-v7.3');
    % % save("/data/eigil/work/lia_kq/Results/dh.mat" , 'dh', '-v7.3');

end