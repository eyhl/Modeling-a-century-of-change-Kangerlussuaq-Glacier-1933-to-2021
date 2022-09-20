function [md, dh, misfit_thk, mean_thicknesses, adam_steps] = modulate_intial_thickness2(md, step_size, n, spatial_smooth, smoothing_factor)
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
            save("/data/eigil/work/lia_kq/Models/tuning_model_adam.mat" , 'md', '-v7.3');
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

        % if spatial_smooth
        %     % extract predicted thickness
        %     pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

        %     % interpolate onto coarse mesh
        %     pred_thickness = averaging(md, pred_thickness, smooth);
        % else
        %     pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');
        % end
        pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

        % compute misfit and MAE
        misfit_thickness = pred_thickness - obs_thickness; 

        % base mae computation on relevant areas
        misfit_thickness(misfit_thickness<-200) = -200;
        misfit_thickness(misfit_thickness>=200) = 200;

        % average nodes
        % misfit_thickness = averaging(md, misfit_thickness, smooth);
        
        %find glacier frony from earlier
        front_area_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here.exp', 2));

        % misfit_thickness(final_levelset > 0) = NaN; % ocean
        misfit_thickness(front_area_pos) = NaN; % ocean / irrelavant front area, cannot be updated
        % misfit_thickness(mask == 1) = NaN; % non-ice areas

        % compute mean abs error
        mae_thickness = mean(abs(misfit_thickness), 'omitnan');

        % remove NaNs, insert 0 misfit
        misfit_thickness(isnan(misfit_thickness)) = 0;
        % plotmodel(md, 'data', misfit_thickness, 'figure', 1, 'caxis', [-300, 300])
    
        % save for statistics and monitoring
        dh(i) = mae_thickness;
        misfit_thk(:, i-1) = misfit_thickness;
        mean_thicknesses(i-1) = mean(pred_thickness, 1);

        % update initial guess
        correction = zeros(size(pred_thickness));
        nodes_with_large_err = abs(misfit_thickness) >= 10;
        correction(nodes_with_large_err) = misfit_thickness(nodes_with_large_err);

        if i > 0
            disp("Gradient step")
            % update only the following
            % area_of_interest = ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/update_thickness_in_area.exp', 2);
            % correction(~area_of_interest) = 0;
            step_size = step_size * 0.8;

            % descent updates
            g = correction;

            regular_step = mean(g, 1); 

            % save status
            fprintf(fid, '%d    %f  %f  %f  %f  %s\n', i-1, mae_thickness, mean_thicknesses(i-1), step_size, regular_step, datetime);

            % update thickness
            H_update = step_size .* g;
            
        else
            disp("Adam step")

            % adam updates
            g = correction;
            m(:, i) = beta_1 .* m(:, i-1) + (1 - beta_1) .* g;
            v(:, i) = beta_2 .* v(:, i-1) + (1 - beta_2) .* g.^2;
            mhat = m(:, i) ./ (1.0 - beta_1 .^ (i-1));
            vhat = v(:, i) ./ (1.0 - beta_2 .^ (i-1));

            % save status
            adam_step = mean(mhat, 1)/(mean(sqrt(vhat), 1) + eps);
            adam_steps(i) = adam_step;
            fprintf(fid, '%d    %f  %f  %f  %f  %s\n', i-1, mae_thickness, mean_thicknesses(i-1), step_size, adam_step, datetime);

            % update thickness
            H_update = step_size .* averaging(md, mhat ./ (sqrt(vhat) + eps) .* abs(g), smooth);

            plotmodel(md, 'data', averaging(md, mhat ./ (sqrt(vhat) + eps), smooth), 'figure', 49, 'title', 'mhat/sqrt(vhat)'); exportgraphics(gcf, sprintf("mhat_vhat%d.png", i-1));

        end

        
        updated_thickness(:, i) = updated_thickness(:, i-1) - H_update;
        % status plotting
        plotmodel(md, 'data', correction, 'figure', 48, 'title', 'misfit', 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("misfit%d.png", i-1));
        plotmodel(md, 'data', H_update, 'figure', 50, 'title', 'update', 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("update%d.png", i-1));
        plotmodel(md, 'data', updated_thickness(:, i) - updated_thickness(:, i-1), 'figure', 51, 'title', 'difference between thickness i and i-1'); exportgraphics(gcf, sprintf("difference%d.png", i-1));
        plotmodel(md, 'data', updated_thickness(:, i), 'figure', 52, 'title', 'current thickness', 'caxis', [0, 2500]); exportgraphics(gcf, sprintf("currentH%d.png", i-1));

        md.geometry.thickness = updated_thickness(:, i); %initial_thickness - step_size * correction;
        pos = find(md.geometry.thickness <= 10);
        md.geometry.thickness(pos) = 10;
        md.geometry.surface = md.geometry.thickness + md.geometry.base;
        plotmodel(md, 'data', md.geometry.surface, 'figure', 53, 'title', 'current surface'); exportgraphics(gcf, sprintf("currentSurf%d.png", i-1));

        % ensure minimum thickness
        pos = find(md.geometry.thickness <= 10);
        md.geometry.surface(pos) = md.geometry.base(pos) + 10; %Minimum thickness
        md.geometry.thickness = md.geometry.surface - md.geometry.base; % thickness=surface-base

        % update transient boundary spc thickness
        pos = find(md.mesh.vertexonboundary);
        md.masstransport.spcthickness(pos, 1) = md.geometry.thickness(pos);

        thickness = md.geometry.thickness;
        surface = md.geometry.surface;
        save(sprintf("/data/eigil/work/lia_kq/misfit_thickness%d.mat", i-1) , 'misfit_thickness', '-v7.3');
        save(sprintf("/data/eigil/work/lia_kq/H_update%d.mat", i-1) , 'H_update', '-v7.3');
        save(sprintf("/data/eigil/work/lia_kq/md.geometry.thickness%d.mat", i-1) , 'thickness', '-v7.3');
        save(sprintf("/data/eigil/work/lia_kq/md.geometry.surface%d.mat", i-1) , 'surface', '-v7.3');
    end
end