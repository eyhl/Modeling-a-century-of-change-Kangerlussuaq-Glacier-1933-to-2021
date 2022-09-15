function [md, dh, misfit_thk, mean_thicknesses, mhat, vhat] = modulate_intial_thickness2(md, step_size, n, spatial_smooth, smoothing_factor)
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

    rng(3)
    % factor for average gradient
    beta_1 = 0.900;
    % factor for average squared gradient
    beta_2 = 0.995;

    dh = zeros(n+1, 1);
    m = zeros(length(md.geometry.surface), n+1);
    v = zeros(length(md.geometry.surface), n+1);

    dh(1) = inf;
    mean_thicknesses = zeros(n+1, 1);
    misfit_thk = zeros(length(md.geometry.surface), n+1);
    obs_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
    obs_thickness = obs_surface - md.geometry.base;

    initial_levelset = md.levelset.spclevelset(1:end-1, 1);
    final_levelset = md.levelset.spclevelset(1:end-1, end);
    mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));

    updated_thickness = zeros(length(md.geometry.surface), n+1);
    updated_thickness(:, 1) = md.geometry.thickness;

    fid = fopen('status.txt','w');
    for i = 2:n+1
        if i-1 ~= 1
            disp('SOLVE')
            md = solve(md,'Transient','runtimename',false); 
            fprintf("SAVE at iteration %d\n", i-1);
            save("/data/eigil/work/lia_kq/Models/tuning_model_adam.mat" , 'md', '-v7.3');
        end

        times = [md.results.TransientSolution.time];
        index_2021 = find(times > 2020 & times < 2022);

        % if spatial_smooth
        %     % extract predicted thickness
        %     pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

        %     % interpolate onto coarse mesh
        %     pred_thickness = averaging(md, pred_thickness, smoothing_factor);
        % else
        %     pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');
        % end
        pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

        % compute misfit and MAE
        misfit_thickness = pred_thickness - obs_thickness; 

        % base mae computation on relevant areas
        misfit_thickness(misfit_thickness<-300) = -300;
        misfit_thickness(misfit_thickness>=300) = 300;

        % average nodes
        misfit_thickness = averaging(md, misfit_thickness, smoothing_factor);
        misfit_thickness(final_levelset > 0) = NaN; % ocean
        misfit_thickness(mask == 1) = NaN; % non-ice areas

        % compute mean abs error
        mae_thickness = mean(abs(misfit_thickness), 'omitnan');

        % remove NaNs, insert 0 misfit
        misfit_thickness(isnan(misfit_thickness)) = 0;
        plotmodel(md, 'data', misfit_thickness, 'figure', 1, 'caxis', [-300, 300])
    
        % save for statistics and monitoring
        dh(i) = mae_thickness;
        misfit_thk(:, i-1) = misfit_thickness;
        mean_thicknesses(i-1) = mean(pred_thickness, 1);

        % update initial guess
        correction = zeros(size(pred_thickness));
        nodes_with_large_err = abs(misfit_thickness) >= 10;
        correction(nodes_with_large_err) = misfit_thickness(nodes_with_large_err);
        
        % adam updates
        g = correction;
        m(:, i) = beta_1 .* m(:, i-1) + (1 - beta_1) .* g;
        v(:, i) = beta_2 .* v(:, i-1) + (1 - beta_2) .* g.^2;
        mhat = m(:, i) ./ (1.0 - beta_1 .^ (i-1));
        vhat = v(:, i) ./ (1.0 - beta_2 .^ (i-1));
        plotmodel(md, 'data', mhat, 'figure', 4, 'title', 'mhat', 'caxis', [-300, 300])
        plotmodel(md, 'data', sqrt(vhat), 'figure', 5, 'title', 'vhat', 'caxis', [-300, 300])
        plotmodel(md, 'data', step_size .* mhat ./ (sqrt(vhat) + eps) .* abs(g), 'figure', 6, 'title', 'update', 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("update%d.png", i-1));

        
        % save status
        fprintf(fid, '%d    %f  %f  %f  %f  %f\n', i-1, mae_thickness, mean_thicknesses(i-1), step_size, mean(mhat, 1), mean(vhat, 1));

        % update thickness
        updated_thickness(:, i) = updated_thickness(:, i-1) - step_size .* mhat ./ (sqrt(vhat) + eps) .* abs(g);

        md.geometry.thickness = updated_thickness(:, i); %initial_thickness - step_size * correction;
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