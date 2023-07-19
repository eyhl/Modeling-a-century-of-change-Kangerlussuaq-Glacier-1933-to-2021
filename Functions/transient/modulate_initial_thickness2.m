function [md, dh, misfit_thk, mean_thicknesses, adam_steps] = modulate_initial_thickness2(md, step_size, n, spatial_smooth, smoothing_factor)
    % if nargin < 3
    %     spatial_smooth = true;
    %     stop_adam_updates = Inf;
    % end
    % if nargin < 4
    %     spatial_smooth = true;
    %     smoothing_factor = 1;
    %     stop_adam_updates = Inf;
    % end
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

    smoothing_factor_schedule = false;
    smooth = smoothing_factor(1);
    if length(smoothing_factor) > 1
        smoothing_factor_schedule = true;
        smooth = smoothing_factor(1);
    end
    config_name = "config-modulation.csv";

    rng(3)
    % factor for average gradient
    beta_1 = 0.900;
    % factor for average squared gradient
    beta_2 = 0.999;

    dh = zeros(n+1, 1);
    adam_steps = zeros(n+1, 1);
    mean_thicknesses = zeros(n, 1);

    dh(1) = inf; adam_steps(1) = NaN;

    m = zeros(length(md.geometry.surface), n+1);
    v = zeros(length(md.geometry.surface), n+1);

    misfit_thk = zeros(length(md.geometry.surface), n+1);
    obs_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
    obs_thickness = obs_surface - md.geometry.base;

    initial_levelset = md.levelset.spclevelset(1:end-1, 1);
    final_levelset = md.levelset.spclevelset(1:end-1, end);
    mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));

    updated_thickness = zeros(length(md.geometry.surface), n+1);
    updated_thickness(:, 1) = md.geometry.thickness;

    fid = fopen('status.txt','w');
    j = 1;
    for i = 2:n+1
        if i-1 ~= 1
            disp('SOLVE')
            md = solve(md,'Transient','runtimename',false); 
            fprintf("SAVE at iteration %d\n", i-1);
            save("/home/eyhli/IceModeling/work/lia_kq/Models/tuning_model_adam.mat" , 'md', '-v7.3');
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
        
        %find glacier frony from earlier
        front_area_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/dont_update_init_H_here.exp', 2));

        % misfit_thickness(final_levelset > 0) = NaN; % ocean
        misfit_thickness(front_area_pos) = NaN; % ocean / irrelavant front area, cannot be updated
        % misfit_thickness(mask == 1) = NaN; % non-ice areas

        % compute mean abs error
        mae_thickness = mean(abs(misfit_thickness), 'omitnan');

        % remove NaNs, insert 0 misfit
        misfit_thickness(isnan(misfit_thickness)) = 0;
    
        % save for statistics and monitoring
        dh(i) = mae_thickness;
        misfit_thk(:, i-1) = misfit_thickness;
        mean_thicknesses(i-1) = mean(pred_thickness, 1);

        % update initial guess
        H_update = zeros(size(pred_thickness));
        nodes_with_large_err = abs(misfit_thickness) >= 10;
        H_update(nodes_with_large_err) = misfit_thickness(nodes_with_large_err);
        plotmodel(md, 'data', H_update, 'figure', 48, 'title', 'misfit', 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("misfit%d.png", i-1));

        if stop_adam_updates >= i
            disp("Adam step")
            [H_update, mean_step, m, v] = adam_step(g, m, v, i, beta_1, beta_2);

            % save status
            adam_steps(i) = mean_step;
            fprintf(fid, '%d    %f  %f  %f  %f  %s\n', i-1, mae_thickness, mean_thicknesses(i-1), step_size, mean_step, datetime);

            % update thickness
            plotmodel(md, 'data', averaging(md, mhat ./ (sqrt(vhat) + eps), smooth), 'figure', 49, 'title', 'mhat/sqrt(vhat)'); exportgraphics(gcf, sprintf("mhat_vhat%d.png", i-1));
        else
            % gradient stepping, update status with mean delta H instead
            regular_step = mean(g, 1); 

            % save status
            fprintf(fid, '%d    %f  %f  %f  %f  %s\n', i-1, mae_thickness, mean_thicknesses(i-1), step_size, regular_step, datetime);
        end

        % apply update
        H_update = averaging(md, H_update, smooth);
        updated_thickness(:, i) = updated_thickness(:, i-1) - step_size .* H_update;

        % status plotting
        plotmodel(md, 'data', H_update, 'figure', 50, 'title', 'update', 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("update%d.png", i-1));
        plotmodel(md, 'data', updated_thickness(:, i) - updated_thickness(:, i-1), 'figure', 51, 'title', 'difference between thickness i and i-1'); exportgraphics(gcf, sprintf("difference%d.png", i-1));
        plotmodel(md, 'data', updated_thickness(:, i), 'figure', 52, 'title', 'current thickness', 'caxis', [0, 2500]); exportgraphics(gcf, sprintf("currentH%d.png", i-1));

        % update initial thickness
        md.geometry.thickness = updated_thickness(:, i); %initial_thickness - step_size * H_update;

        % ensure minimum thickness
        pos = find(md.geometry.thickness <= 10);
        md.geometry.thickness(pos) = 10;
        md.geometry.surface = md.geometry.thickness + md.geometry.base;
        plotmodel(md, 'data', md.geometry.surface, 'figure', 53, 'title', 'current surface'); exportgraphics(gcf, sprintf("currentSurf%d.png", i-1));

        pos = find(md.geometry.thickness <= 10);
        md.geometry.surface(pos) = md.geometry.base(pos) + 10; %Minimum thickness
        md.geometry.thickness = md.geometry.surface - md.geometry.base; % thickness=surface-base

        % update transient boundary spc thickness
        pos = find(md.mesh.vertexonboundary);
        md.masstransport.spcthickness(pos, 1) = md.geometry.thickness(pos);

        % for saving the variables
        thickness = md.geometry.thickness;
        surface = md.geometry.surface;
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/misfit_thickness%d.mat", i-1) , 'misfit_thickness', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/H_update%d.mat", i-1) , 'H_update', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/md.geometry.thickness%d.mat", i-1) , 'thickness', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/md.geometry.surface%d.mat", i-1) , 'surface', '-v7.3');
    end
end