function [misfit, mae_total, mae_basin] = compute_thickness_misfit(md, year_span, error_cap)
    if nargin < 3
        error_cap = false;
    end

    times = [md.results.TransientSolution.time];
    time_indeces = find(times > year_span(1) & times < year_span(2));
    basin_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/thickness_misfit_aoi.exp', 2));

    % use relevant observed data
    if year_span(2) < 2010  % bedmachine data
        % bedmachine thickness
        bed  = interpBmGreenland(md.mesh.x,md.mesh.y,'bed');
        surface = interpBmGreenland(md.mesh.x,md.mesh.y,'surface');
        obs_thickness = surface - bed;
    else  % icesat 2 data
        % load observed thickness in 2021 from Ice Sat 2
        obs_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
        obs_thickness = obs_surface - md.geometry.base;
    end
    pred_thickness = mean([md.results.TransientSolution(time_indeces).Thickness], 2, 'omitnan');

    % compute misfit and MAE
    misfit = pred_thickness - obs_thickness; 

    if error_cap
        % base mae computation on relevant areas
        misfit(misfit<-error_cap) = -error_cap;
        misfit(misfit>=error_cap) = error_cap;
    end
    
    % remove ice-free areas:
    ice_levelset_end_of_year = md.results.TransientSolution(time_indeces(end)).MaskIceLevelset; % could also be the first one
    ice_free_pos = ice_levelset_end_of_year > 0;
    misfit(ice_free_pos) = NaN; % ocean / irrelavant front area, cannot be updated
    % misfit(mask == 1) = NaN; % non-ice areas

    % compute mean abs error
    mae_total = mean(abs(misfit), 'omitnan');

    misft_basin = misfit(basin_pos);
    mae_basin = mean(abs(misft_basin), 'omitnan');

    % remove NaNs, insert 0 misfit
    misfit(isnan(misfit)) = 0;
end