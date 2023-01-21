function [fjord_shape] = get_fjord_shape(calfin_path)
    %% GET_FJORD_SHAPE() assumes you want to use the shape with the
    % largest area in a stack as the fjord outline. This would work
    % for extracting the most retreated front in calfin and autoterm
    % datasets. In general you might want define your fjord manually.
    
    shape_table = get_calfin_stack(calfin_path);
    [area, index] = get_largest_shape(shape_table);
    % fjord_shape = [shape_table.X{index}; shape_table.Y{index}];
    X = shape_table.X{index};
    Y = shape_table.Y{index};
    fjord_shape = table({X}, {Y},'VariableNames',["X", "Y"]); % the {} is not necessary, but keeps notation consistent in rest of code
end