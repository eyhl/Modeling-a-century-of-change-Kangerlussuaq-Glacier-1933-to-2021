function [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md)
    % load bedmachine mask and time steps
    mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
    times = [md.results.TransientSolution.time];
    
    %% THICKNESS
    % interpolate 2021 surface
    surface = interp2021Surface(md);                             
    surface(isnan(surface)) = md.geometry.surface(isnan(surface)); % add 2007 surface to NaN in borders

    % compute 2021 thickness
    obs_thickness = surface - md.geometry.bed;
    % obs_thickness(md.mask.ice_levelset == 1) = NaN; % remove ocean                     
    % obs_thickness(mask == 1) = NaN; % remove ice-free areas
    
    % extract predicted thickness
    index_2021 = find(times > 2020 & times < 2022);
    pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');
    % pred_thickness(md.mask.ice_levelset == 1) = NaN; % remove ocean                     
    % pred_thickness(mask == 1) = NaN; % remove ice-free areas
    % disp(size(obs_thickness))
    % disp(size(pred_thickness))
    misfit_thickness = pred_thickness - obs_thickness;

    rmse_thickness = sqrt(mean((misfit_thickness) .^ 2, 'omitnan'));

    %% VELOCITY
    index_MEaSURE = find(times > 1995 & times < 2015);
    data_vx = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vx_v1.tif';
    data_vy = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vy_v1.tif';
    [obs_velocity, ~, ~] = interpVelocity(md, data_vx, data_vy);
    % obs_velocity(md.mask.ice_levelset == 1) = NaN; % remove ocean                     
    % obs_velocity(mask == 1) = NaN; % remove ice-free areas

    pred_velocity = mean([md.results.TransientSolution(index_MEaSURE).Vel], 2, 'omitnan');
    % pred_velocity(md.mask.ice_levelset == 1) = NaN; % remove ocean                     
    % pred_velocity(mask == 1) = NaN; % remove ice-free areas
    misfit_velocity = pred_velocity - obs_velocity;

    % TODO: re-introduce NaN, and replace NaN with 0 misfit before returning.

    rmse_velocity = sqrt(mean((misfit_velocity) .^ 2, 'omitnan'));
    
end