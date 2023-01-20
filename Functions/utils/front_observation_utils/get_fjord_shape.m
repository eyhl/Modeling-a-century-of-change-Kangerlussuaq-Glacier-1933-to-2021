function [fjord_shape] = get_fjord_shape(calfin_path)
    shape_table = load_calfin(calfin_path);
    [area, index] = get_largest_shape(shape_table);
    % fjord_shape = [shape_table.X{index}; shape_table.Y{index}];
    X = shape_table.X{index};
    Y = shape_table.Y{index};
    fjord_shape = table({X}, {Y},'VariableNames',["X", "Y"]); % the {} is not necessary, but keeps notation consistent in rest of code
end