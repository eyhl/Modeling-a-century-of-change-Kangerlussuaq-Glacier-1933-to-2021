function [md] = temperature_linear_model(md, validate_flag)
    
    if nargin < 2
        validate_flag = false;
    end

    %% LOAD DATA AND CREATE RELEVANT VARIABLES
    extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area_temp.exp', 2));
    temperature_field = md.miscellaneous.dummy.temperature_field;

    % assign temp. variables
    temperature_data = temperature_field;
    x = md.mesh.x;
    y = md.mesh.y;

    % remove unknown area
    temperature_data(extrapolated_pos) = [];
    x(extrapolated_pos) = [];
    y(extrapolated_pos) = [];

    % create friction interpolant
    F = scatteredInterpolant(x, y, temperature_data, 'natural', 'linear');
    extrapolated_temperature = F(md.mesh.x(extrapolated_pos), md.mesh.y(extrapolated_pos));

    if validate_flag
        temperature_field(extrapolated_pos) = extrapolated_temperature;    
        plotmodel(md, 'data', temperature_field, 'figure', 82, 'title', 'Temperature', ...
        'colorbar', 'off', 'xtick', [], 'ytick', []); 
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        title(h, "Temperature field")
        colormap('turbo')
        exportgraphics(gcf, "temp_field_linear.png")
    end

end