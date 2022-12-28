function [extrapolated_friction, extrapolated_pos, mae] = friction_random_field_model(md, cs_min, friction_law, validate_flag)
    %--
    % Extrapolates friction data based on a gaussian random field. It computes the std and
    % mean from the data, but correlation length is hard-coded (determined from plot)
    % Returns area with new values in 0 areas, and the positions of the front area, 
    % and replaced value positions
    % Update October 2022: 
        % The method produces qualitatively meaninful features, despite having to 
        % set the features to be ~140 the feature size (most likely due to missing understanding of kriging approach)
        % It annoyed me that regular linear extrapolation of the field based on correlation with bed topo works better.
        % However, I realised that this is due to the fact that the linear correlation based method has information 
        % about the bed topography, whereas the RF method does not. If it is possible to do Gauss simulations like below
        % conditioned on the bed topography - this would most likely yield much more realistic simulations. 
    %--

    if nargin < 4
        validate_flag = false;
    end

    if strcmp(friction_law, 'budd')
        friction_field = md.friction.coefficient; % budd
        x_corr_mean = 1.2678e+03;
        y_corr_mean = 1.9525e+03;

    elseif strcmp(friction_law, 'schoof')
        friction_field = md.friction.C; % schoof
        factor = 140; % needed for gauss method, but not sure why.
        x_corr_mean = factor * 2.8721e+03; % computed by reading off from plot 
        y_corr_mean = factor * 5.0916e+03; % computed by reading off from plot 

    else
        warning("Friction Law not known: choose budd or schoof")
    end

    rng('default')
    addpath(genpath('Functions/SeReM/'))

    %find glacier frony from earlier
    extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area.exp', 2));
    friction_data_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_utils/friction_data.exp', 2));
    friction_validation_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_utils/friction_validation.exp', 2));
    friction_val = friction_field(friction_validation_pos);

    % TODO: change to md.results.Stressbalancesolution.friction -> remove averaging 
    % extrapolated_friction = friction_field(extrapolated_pos); % budd, average in time                                                                     

    % get corresponding coords
    x = md.mesh.x(extrapolated_pos);
    y = md.mesh.y(extrapolated_pos);

    rf_field_size = 1.2e2;

    % define grid to interpolate onto
    xq = linspace(min(x), max(x), rf_field_size);
    yq = linspace(min(y), max(y), rf_field_size);
    [Xq, Yq] = ndgrid(xq, yq);
    mesh = [Xq(:) Yq(:)]; % structure for randomfield function

    % extract mean and std from friction coefficient field, in area under the ice. 
    tmp_mean = mean(friction_field(friction_data_pos), 'omitnan');
    tmp_std = std(friction_field(friction_data_pos), 'omitnan');

    % create corr struct for randomfield()
    corr_struct.name = 'gauss';
    corr_struct.c0 = [x_corr_mean, y_corr_mean];  % anisotropic
    % 'gauss' looks much better, but needs corr ~140 times larger to match actual features.
    % 'exp' corr ~1/2 times smaller to match actual features.

    corr_struct.sigma = tmp_std ^ 2;

    disp('Generating Random Friction field');
    % compute random field, generating more samples is quick (init is slow)
    RF = randomfield(corr_struct, mesh, 'nsamples', 1000, 'mean', tmp_mean);

    if validate_flag
        x_val = md.mesh.x(friction_validation_pos);
        y_val = md.mesh.y(friction_validation_pos);
        for i=1:1000
            G = griddedInterpolant(Xq, Yq, reshape(RF(:, i), rf_field_size, rf_field_size));

            %% Validate
            extrapolated_friction_val = G(x_val, y_val);
            mae(i) = mean(abs(friction_val - extrapolated_friction_val));

        end
        [val, ind] = min(mae)
        mae = val;
    else
        val = 1e3;
        ind = 490; % selected from prior runs
        mae = NaN;
    end

    G = griddedInterpolant(Xq, Yq, reshape(RF(:, ind), rf_field_size, rf_field_size));
    extrapolated_friction = G(x, y);
    extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
    friction_field(extrapolated_pos) = extrapolated_friction;

    if validate_flag
        title_string = sprintf('MAE = %.2f', val)
        plotmodel(md, 'data', friction_field, 'figure', 83, 'title', title_string, ...
        'colorbar', 'off', 'xtick', [], 'ytick', []); 
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        title(h, "Friction Coefficient")
        colormap('turbo') 
        expdisp('/data/eigil/work/lia_kq/Exp/extrapolation_utils/friction_data.exp', 'linewidth', 1, 'linestyle', 'r--')
        expdisp('/data/eigil/work/lia_kq/Exp/extrapolation_utils/friction_validation.exp', 'linewidth', 1, 'linestyle', 'r--')
        exportgraphics(gcf, "friction_field_rf.png")
    end

end