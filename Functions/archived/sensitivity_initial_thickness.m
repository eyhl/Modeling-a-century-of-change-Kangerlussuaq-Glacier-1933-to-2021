function [md, mae_list, misfit_thk, mean_thicknesses] = sensitivity_initial_thickness(md, sensitivity_factors)
    % sensitivity_factors = [0.5, 1.0, 1.5, 2.0, 2.5, 3, 3.5, 4, 4.5, 5.0];
    n = length(sensitivity_factors);
    md_orig = md;

    % time indeces
    times = [md.results.TransientSolution.time];
    index_2021 = find(times > 2020 & times < 2022);

    % observed surface
    obs_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
    obs_thickness = obs_surface - md.geometry.base;

    % initialisation
    mae_list = zeros(n+1, 1);
    mean_thicknesses = zeros(n, 1);
    misfit_thk = zeros(length(md.geometry.surface), n+1);
    front_area_small = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/fast_flow/dont_update_init_H_here_small.exp', 2));
    front_area_large = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/fast_flow/dont_update_init_H_here_large.exp', 2));

    smooth = 20;

    fid = fopen('status.txt','w');

    for i=1:n
        md = md_orig;

        % time indeces
        times = [md.results.TransientSolution.time];
        index_2021 = find(times > 2020 & times < 2022);

        pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

        % compute misfit and MAE
        misfit_thickness = pred_thickness - obs_thickness; 

        % base mae computation on relevant areas
        misfit_thickness(misfit_thickness<-200) = -200;
        misfit_thickness(misfit_thickness>=200) = 200;
        
        % misfit_thickness(final_levelset > 0) = NaN; % ocean
        misfit_thickness(front_area_small) = 0; % ocean / irrelavant front area, cannot be updated
        % misfit_thickness(mask == 1) = NaN; % non-ice areas

        % update initial guess
        dH = zeros(size(pred_thickness));
        nodes_with_large_err = abs(misfit_thickness) >= 10;
        dH(nodes_with_large_err) = misfit_thickness(nodes_with_large_err);

        % % propagate positions back in time 
        [x_back, y_back] = flowline_traceback(md, false);

        % interpolate to relevant 1900 points
        F = scatteredInterpolant(x_back(:, end), y_back(:, end), dH, 'nearest', 'nearest');
        dH = F(md.mesh.x, md.mesh.y);

        % smooth update
        dH = averaging(md, dH, smooth);

        % remove area with points that end up in the water.
        dH(front_area_large) = 0;

        % update thickness
        md.geometry.thickness = md.geometry.thickness - sensitivity_factors(i) .* dH;

        % ensure minimum thickness
        pos = find(md.geometry.thickness <= 10);
        md.geometry.surface(pos) = md.geometry.base(pos) + 10; %Minimum thickness
        md.geometry.thickness = md.geometry.surface - md.geometry.base; % thickness=surface-base

        % update transient boundary spc thickness
        pos = find(md.mesh.vertexonboundary);
        md.masstransport.spcthickness(pos, 1) = md.geometry.thickness(pos);

        disp('SOLVE')
        md = solve(md, 'Transient', 'runtimename',false); 
        fprintf("SAVE at iteration %d\n", i);
        save("/home/eyhli/IceModeling/work/lia_kq/Models/sensitivity_init_thickness.mat" , 'md', '-v7.3');

        % time indeces
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
        misfit_thk(:, i) = misfit_thickness;
        mean_thicknesses(i) = mean(pred_thickness, 1);


        % status plotting
        plotmodel(md, 'data', md.geometry.surface, 'figure', 53, 'title', sprintf('Init surface, factor=%f\n', sensitivity_factors(i))); exportgraphics(gcf, sprintf("currentSurf%d.png", sensitivity_factors(i)));
        plotmodel(md, 'data', misfit_thickness, 'figure', 48, 'title', sprintf('Misfit, factor=%f\n', sensitivity_factors(i)), 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("misfit%d.png", sensitivity_factors(i)));
        plotmodel(md, 'data', dH, 'figure', 50, 'title', sprintf('Update, factor=%f\n', sensitivity_factors(i)), 'caxis', [-300, 300]); exportgraphics(gcf, sprintf("update%d.png", sensitivity_factors(i)));
        plotmodel(md, 'data', md.geometry.thickness, 'figure', 52, 'title', sprintf('Init thickness, factor=%f\n', sensitivity_factors(i)), 'caxis', [0, 2500]); exportgraphics(gcf, sprintf("currentH%d.png", sensitivity_factors(i)));
        fprintf(fid, '%d  %f  %f  %f  %s\n', i, mae_thickness, mean_thicknesses(i), sensitivity_factors(i), datetime);

        % for saving the variables
        thickness = md.geometry.thickness;
        surface = md.geometry.surface;
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/misfit_thickness%d.mat", sensitivity_factors(i)) , 'misfit_thickness', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/dH%d.mat", sensitivity_factors(i)) , 'dH', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/md.geometry.thickness%d.mat", sensitivity_factors(i)) , 'thickness', '-v7.3');
        save(sprintf("/home/eyhli/IceModeling/work/lia_kq/md.geometry.surface%d.mat", sensitivity_factors(i)) , 'surface', '-v7.3');
        
    end

end