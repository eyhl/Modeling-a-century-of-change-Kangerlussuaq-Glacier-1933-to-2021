function [front_area_friction, front_area_pos] = extrapolate_friction_const(md)
    %--
    % Extrapolates smb data based on a gaussian random field. It computes the std and
    % mean from the data, but correlation length is hard-coded (determined from plot)
    % Returns area with new values in 0 areas, and the positions of the front area, 
    % and replaced value positions
    %--
    rng('default')
    addpath(genpath('Functions/SeReM/'))

    %find glacier frony from earlier
    front_area_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area.exp', 2));
    friction_stat_area = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/friction_statistics.exp', 2));

    % TODO: change to md.results.Stressbalancesolution.friction -> remove averaging 
    front_area_friction = md.friction.coefficient(front_area_pos); % average in time                                                                     

    % get corresponding coords
    x = md.mesh.x(front_area_pos);
    y = md.mesh.y(front_area_pos);

    rf_field_size = 1.2e2;

    % define grid to interpolate onto
    xq = linspace(min(x), max(x), rf_field_size);
    yq = linspace(min(y), max(y), rf_field_size);
    [Xq, Yq] = ndgrid(xq, yq);
    mesh = [Xq(:) Yq(:)]; % structure for randomfield function

    % set approximate spatial correlation length, read off from plot
    % average from 2 different features for robustness 
    % (mean of left/right and up/down distance)
    x_dist1 = mean(abs(480341 - [479149, 482071]));
    y_dist1 = mean(abs(-2279530 - [-2277270, -2281470]));
    x_dist2 = mean(abs(477346 - [476074, 478223]));
    y_dist2 = mean(abs(-2270860 - [-2268440, -2272050]));
    
    % take average of feature sizes
    % NOTE: x and y are swapped on purpose to cohere with fjord orientation
    est_corr_dist_y = mean([x_dist1, x_dist2]); 
    est_corr_dist_x = mean([y_dist1, y_dist2]);

    est_corr_dist_y = est_corr_dist_y - 0.5 * est_corr_dist_y; 
    est_corr_dist_x = est_corr_dist_x - 0.5 * est_corr_dist_x;

    % extract mean and std from friction coefficient field, in area under the ice. 
    tmp_mean = nanmean(md.friction.coefficient(friction_stat_area));
    tmp_std = nanstd(md.friction.coefficient(friction_stat_area));

    % create corr struct for randomfield()
    corr_struct.name = 'exp';
    corr_struct.c0 = [est_corr_dist_x, est_corr_dist_y];  % anisotropic
    corr_struct.sigma = tmp_std ^ 2;

    disp('Generating Random Friction field');
    % compute random field, generating more samples is quick (init is slow)
    RF1 = randomfield(corr_struct, mesh, 'nsamples', 10, 'mean', tmp_mean);
    corr_struct.name = 'gauss';
    RF2 = randomfield(corr_struct, mesh, 'nsamples', 10, 'mean', tmp_mean);

    RF = (RF1 + RF2) ./ 2;

     % weigh by bedrock, only low elevation as most of front area is negative elevation
    % so normalising using everything creates values almost 0 in all of front area.
    bed_norm = md.geometry.bed;
    bed_norm(bed_norm > -700) = NaN; % selected based on inspection, this is a thin valley in cetre of glacier bed
    bed_norm = (bed_norm - min(bed_norm)) ./ (max(bed_norm) - min(bed_norm)); % normalise
    bed_norm = bed_norm * 0.80; % reduce weights in valley to be between 0 and 0.75
    bed_norm(isnan(bed_norm)) = 1.2; % Values in front area above -750 are given a higher weight to retain glacier flow

    % estimated from Brough et al 2019, the approx mean btw 0.5 and 5km vel from 2018 front
    % mean_vel_at_front = 8e3; 
    % md_tmp = md;
    % rmse = zeros(10, 1);
    % for i=1:10
    %     % define gridded interpolator based on RF
    %     G = griddedInterpolant(Xq, Yq, reshape(RF(:, i), rf_field_size, rf_field_size));
   
    %     % interpolate onto original data coordinates and weigh by bedrock
    %     front_area_friction = abs(G(x, y)) .* bed_norm(front_area_pos);

    %     % insert friction into model
    %     md_tmp.friction.coefficient(front_area_pos) = front_area_friction;

    %     md_tmp.inversion.iscontrol = 0;
    %     md_tmp = solve(md_tmp, 'Stressbalance');

    %     pred_vel = md_tmp.results.StressbalanceSolution.Vel(front_area_pos);

    %     rmse(i) = sqrt(mean((pred_vel - mean_vel_at_front) .^ 2));
    %     disp(i)
    %     disp(rmse(i))
    % end

    % [min_rmse, index] = min(rmse);
    index = 10; % i think i chose this from experimenting - I should probably choose based on misfit.

    G = griddedInterpolant(Xq, Yq, reshape(RF(:, index), rf_field_size, rf_field_size));
    front_area_friction = abs(G(x, y)) .* bed_norm(front_area_pos);
end