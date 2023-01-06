function [extrapolated_friction, extrapolated_pos, mae] = friction_correlation_model(md, cs_min, M, friction_law, validate_flag)

    if nargin < 3
        validate_flag = false;
    end

    if strcmp(friction_law, 'budd')
        friction_field = md.friction.coefficient; % budd
    elseif strcmp(friction_law, 'schoof')
        friction_field = md.friction.C; % schoof
    elseif strcmp(friction_law, 'weertman')
        friction_field = md.friction.C; % weertman
    elseif strcmp(friction_law, 'regcoulomb')
        friction_field = md.friction.C; % weertman
    else
        warning("Friction Law not known: choose budd or schoof")
    end

    %% LOAD DATA AND CREATE RELEVANT VARIABLES
    friction_data_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_utils/friction_data.exp', 2));
    friction_validation = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_utils/friction_validation.exp', 2));
    extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp', 2));

    % preprocess model data
    friction_data = friction_field(friction_data_pos);
    friction_data_mean = mean(friction_data, 1);
    friction_data_std = std(friction_data, 1);
    friction_data_normalised = (friction_data - friction_data_mean) / friction_data_std;
    bed_data = md.geometry.bed(friction_data_pos);
    bed_data_normalised = (bed_data - mean(bed_data)) / std(bed_data); 
    
    % preprocess validation data
    friction_val = friction_field(friction_validation);
    friction_val_normalised = (friction_val - friction_data_mean) / friction_data_std;
    bed_val = md.geometry.bed(friction_validation);
    bed_val_normalised = (bed_val - mean(bed_data)) / std(bed_data); 

    % extrapolation area
    bed_front = md.geometry.bed(extrapolated_pos);
    bed_front_normalised = (bed_front - mean(bed_data)) / std(bed_data); 

    %% Polynomial basis model
    G = ones(length(bed_data_normalised), 1);
    size(G)
    for n = 1:M
        G = [G, bed_data_normalised.^n];
    end
    m = G \ friction_data_normalised;

    if validate_flag
        %% Validate
        G = ones(length(bed_val_normalised), 1);
        for n = 1:M
            G = [G, bed_val_normalised.^n];
        end
        friction_syn = G * m;
        friction_syn = friction_syn * friction_data_std + friction_data_mean;
        mae = mean(abs(friction_val - friction_syn));

        %% Plotting
        x_syn = linspace(min(bed_val_normalised), max(bed_val_normalised), 100)';
        G = ones(length(x_syn), 1);
        for n = 1:M
            G = [G, x_syn.^n];
        end
        friction_plot = G * m;
        friction_plot = friction_plot * friction_data_std + friction_data_mean;

        figure(821);                                                                                                                                  
        scatter(bed_val_normalised, friction_val); 
        hold on; 
        title(sprintf('MAE in validation area = %f', mae))
        plot(x_syn, friction_plot);
        exportgraphics(gcf, "bed_friction_correlation.png")
    else
        mae = 800; % from earlier runs    
    end

    %% Extrapolate into front area using polynomial basis,
    G_front = ones(length(bed_front_normalised), 1);
    for n = 1:M
        G_front = [G_front, bed_front_normalised.^n];
    end
    extrapolated_friction = G_front * m;
    extrapolated_friction = extrapolated_friction * friction_data_std + friction_data_mean;

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
        expdisp('/data/eigil/work/lia_kq/Exp/extrapolation_utils/friction_data.exp', 'linewidth', 1, 'linestyle', 'r--')
        expdisp('/data/eigil/work/lia_kq/Exp/extrapolation_utils/friction_validation.exp', 'linewidth', 1, 'linestyle', 'r--')
        exportgraphics(gcf, "friction_field_poly.png")
    end
end