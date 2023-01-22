function [fjord_shape] = get_fjord_shape(path, find_or_load)
    %% GET_FJORD_SHAPE() assumes you want to use the shape with the
    % largest area in a stack as the fjord outline. This would work
    % for extracting the most retreated front in calfin and autoterm
    % datasets. In general you might want define your fjord manually.
    
    % either find the largest shape or load directly
    if strcmp(find_or_load, 'find')
        shape_table = get_calfin_stack(path);
        [~, index] = get_largest_shape(shape_table);
    else 
        shape_table = shaperead(path);
    end

    X = shape_table.X{index};
    Y = shape_table.Y{index};
    fjord_shape = table({X}, {Y},'VariableNames',["X", "Y"]); % the {} is not necessary, but keeps notation consistent in rest of code
end