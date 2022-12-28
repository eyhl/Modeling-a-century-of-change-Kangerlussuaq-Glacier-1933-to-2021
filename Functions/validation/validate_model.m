function [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md)
    % load bedmachine mask and time steps
    mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
    times = [md.results.TransientSolution.time];
    
    %% THICKNESS
    % interpolate 2021 surface
    surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
    surface(isnan(surface)) = md.geometry.surface(isnan(surface)); % add 2007 surface to NaN in borders

    % compute 2021 thickness
    obs_thickness = surface - md.geometry.bed;

    % extract predicted thickness
    index_2021 = find(times > 2020 & times < 2022);
    pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');
    misfit_thickness = pred_thickness - obs_thickness;


    %% VELOCITY
    index_MEaSURE = find(times > 1995 & times < 2015);
    data_vx = '/data/eigil/work/lia_kq/Data/measure_multi_year_v1/greenland_vel_mosaic250_vx_v1.tif'; 
    data_vy = '/data/eigil/work/lia_kq/Data/measure_multi_year_v1/greenland_vel_mosaic250_vy_v1.tif';
    [obs_velocity, ~, ~] = interpVelocity(md, data_vx, data_vy);
    pred_velocity = mean([md.results.TransientSolution(index_MEaSURE).Vel], 2, 'omitnan');
    misfit_velocity = pred_velocity - obs_velocity;

    % base rmse computation on relevant areas
    misfit_thickness(md.mask.ice_levelset == 1) = NaN; % ocean
    misfit_thickness(mask == 1) = NaN; % non-ice areas
    misfit_velocity(md.mask.ice_levelset == 1) = NaN;
    misfit_velocity(mask == 1) = NaN;

    rmse_thickness = sqrt(mean((misfit_thickness) .^ 2, 'omitnan'));
    rmse_velocity = sqrt(mean((misfit_velocity) .^ 2, 'omitnan'));

    % remove nans and replace with 0, i.e. no misfit
    misfit_thickness(isnan(misfit_thickness)) = 0;
    misfit_velocity(isnan(misfit_thickness)) = 0;
end