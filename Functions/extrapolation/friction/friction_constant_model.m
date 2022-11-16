function [extrapolated_friction, extrapolated_pos, mae] = friction_constant_model(md, cs_min, friction_law, validate_flag)
    %--
    % Extrapolates friction data based on the average value, i.e. constant extrapolation
    %--
    if nargin < 3
        validate_flag = false;
    end

    if strcmp(friction_law, 'budd')
        friction_field = md.friction.coefficient; % budd
    elseif strcmp(friction_law, 'schoof')
        friction_field = md.friction.C; % schoof
    else
        warning("Friction Law not known: choose budd or schoof")
    end

    %% LOAD DATA AND CREATE RELEVANT VARIABLES
    friction_data_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/friction_data.exp', 2));
    friction_validation = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/friction_validation.exp', 2));
    extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area.exp', 2));

    % preprocess model data
    friction_data = friction_field(friction_data_pos);
    mean_friction = mean(friction_data, 1);
    extrapolated_friction = ones(length(friction_field(extrapolated_pos)), 1) .* mean_friction;

    if validate_flag
        % preprocess validation data
        friction_val = friction_field(friction_validation);
        
        %% Validate
        mae = mean(abs(friction_val - ones(length(friction_val), 1) .* mean_friction));

        
        title_string = sprintf('MAE = %.2f', mae);
        plotmodel(md, 'data', friction_field, 'figure', 81, 'title', title_string, ...
        'colorbar', 'off', 'xtick', [], 'ytick', []); 
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        title(h, "Friction Coefficient")
        colormap('turbo') 
        expdisp('/data/eigil/work/lia_kq/Exp/friction_data.exp', 'linewidth', 1, 'linestyle', 'r--')
        expdisp('/data/eigil/work/lia_kq/Exp/friction_validation.exp', 'linewidth', 1, 'linestyle', 'r--')
        exportgraphics(gcf, "friction_field_const.png")
    else
        mae = 800; % from earlier runs    
    end
end