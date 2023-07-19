function [front_area_smb, front_area_pos] = smb_random_field_model(md)
    %--
    % Extrapolates smb data based on a gaussian random field. It computes the std and
    % mean from the data, but correlation length is hard-coded (determined from plot)
    % Returns area with new values in 0 areas, and the positions of the front area, 
    % and replaced value positions
    %--
    rng('default')
    addpath(genpath('Functions/SeReM/'))

    %find glacier front area from earlier. The .exp covers a larger area than needed, but non-zero pixels are not altered.
    front_area_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/1900_extrapolation_area.exp', 2));
    front_area_smb = mean(md.smb.mass_balance(front_area_pos, :), 2);                                                                      

    % get corresponding coords
    x = md.mesh.x(front_area_pos);
    y = md.mesh.y(front_area_pos);

    % define grid to interpolate onto
    xq = linspace(min(x), max(x), 1e2);
    yq = linspace(min(y), max(y), 1e2);
    [Xq, Yq] = ndgrid(xq, yq);
    mesh = [Xq(:) Yq(:)]; % structure for randomfield function

    % set approximate spatial correlation length, read off from plot
    % average from 3 different features for robustness
    x_dist1 = mean(abs(495483 - [492740, 497733]));
    y_dist1 = mean(abs(-2292770 - [-2293940, -2291780]));
    x_dist2 = mean(abs(487590 - [485610, 489866]));
    y_dist2 = mean(abs(-2288080 - [-2289410, -2286220]));
    x_dist3 = mean(abs(490442 - [488285, 492740]));
    y_dist3 = mean(abs(-2292580 - [-2293790, -2291500]));

    est_corr_dist_x = mean([x_dist1, x_dist2, x_dist3]); 
    est_corr_dist_y = mean([y_dist1, y_dist2, y_dist3]);

    % extract mean and std from data with meaningful smb. 
    % On average values above -1.4 are related to ocean or front-ocean interface in the relevant area:
    % setting to zero creates a clear boundary between real and extrapolated values
    zero_pos = find(front_area_smb > -1.5);
    tmp_values = front_area_smb; 
    tmp_values(zero_pos) = NaN;
    tmp_mean = nanmean(tmp_values);
    tmp_std = nanstd(tmp_values);

    % create corr struct for randomfield()
    corr_struct.name = 'exp';
    corr_struct.c0 = [est_corr_dist_x, est_corr_dist_y];  % anisotropic
    corr_struct.sigma = tmp_std ^ 2;

    disp('Generating Random SMB field');
    % compute random field, generating more samples is quick (init is slow)
    RF = randomfield(corr_struct, mesh, 'nsamples', 1, 'mean', tmp_mean);

    % define gridded interpolator based on RF
    G = griddedInterpolant(Xq, Yq, reshape(RF, 100, 100));

    % interpolate onto original data coordinates
    vq = G(x(zero_pos), y(zero_pos));

    % set random field values back into smb
    front_area_smb(zero_pos) = vq;
end