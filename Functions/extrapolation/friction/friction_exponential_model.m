function [extrapolated_friction, extrapolated_pos, mae] = friction_exponential_model(md, cs_min, friction_law, validate_flag)

    if nargin < 3
        validate_flag = false;
    end

    if strcmp(friction_law, 'budd')
        friction_field = md.friction.coefficient; % budd
    elseif strcmp(friction_law, 'schoof')
        friction_field = md.friction.C; % schoof
    elseif strcmp(friction_law, 'weertman')
        friction_field = md.friction.C; % weertman
    else
        warning("Friction Law not known: choose budd or schoof")
    end

    %% LOAD DATA AND CREATE RELEVANT VARIABLES
    friction_data_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/friction_data_large.exp', 2));
    friction_validation = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/friction_validation.exp', 2));
    extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area_slim.exp', 2));

    % preprocess model data
    friction_data = friction_field(friction_data_pos);
    friction_data_mean = mean(friction_data, 1);
    friction_data_std = std(friction_data, 1);
    bed_data = md.geometry.bed(friction_data_pos);

    % preprocess validation data
    friction_val = friction_field(friction_validation);
    bed_val = md.geometry.bed(friction_validation);

    % extrapolation area
    bed_front = md.geometry.bed(extrapolated_pos);

    %% Exponential 1-term model
    f = fit(bed_data, friction_data, 'exp1');

    if validate_flag
        %% Validate
        friction_syn = f(bed_val); 
        mae = mean(abs(friction_val - friction_syn));

        %% Plotting
        bed_plot = linspace(min(bed_val), max(bed_val), 100)';
        friction_plot = f(bed_plot); 

        figure(821);                                                                                                                                  
        scatter(bed_val, friction_val); 
        hold on; 
        title(sprintf('MAE in validation area = %f', mae))
        plot(bed_plot, friction_plot);
        exportgraphics(gcf, "bed_friction_correlation.png")
    else
        mae = 800; % from earlier runs    
    end

    %% Extrapolate into front area using polynomial basis,
    extrapolated_friction = f(bed_front); 

    friction_field(extrapolated_pos) = extrapolated_friction;    
    friction_field(friction_field <= cs_min) = cs_min;

    if validate_flag
        title_string = sprintf('MAE = %.2f', mae);
        plotmodel(md, 'data', friction_field, 'figure', 82, 'title', title_string, ...
        'colorbar', 'off', 'xtick', [], 'ytick', []); 
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        title(h, "Friction Coefficient")
        colormap('turbo')
        expdisp('/data/eigil/work/lia_kq/Exp/friction_data.exp', 'linewidth', 1, 'linestyle', 'r--')
        expdisp('/data/eigil/work/lia_kq/Exp/friction_validation.exp', 'linewidth', 1, 'linestyle', 'r--')
        exportgraphics(gcf, "friction_field_poly.png")
    end
end