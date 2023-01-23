function [fjord_shape] = get_fjord_shape(path, find_or_load)
    %% GET_FJORD_SHAPE() assumes you want to use the shape with the
    % largest area in a stack as the fjord outline. This would work
    % for extracting the most retreated front in calfin and autoterm
    % datasets. In general you might want define your fjord manually.
    
    % either find the largest shape or load directly
    if strcmp(find_or_load, 'find')
        shape_table = get_calfin_stack(path);
        [~, index] = get_largest_shape(shape_table);

        % retain only relevant variables
        X = shape_table.X{index};
        Y = shape_table.Y{index};
        fjord_shape = table({X}, {Y},'VariableNames',["X", "Y"]); % the {} is not necessary, but keeps notation consistent in rest of code
    
        % needed for saving shape to correct format
        fjord_shape.Geometry = repmat("Line", height(fjord), 1);
        fjord_shape.Date = repmat("1900-1-1", height(fjord), 1);  
    else 
        shape_table = shaperead(path);
        fjord_shape = struct2table(shape_table, 'AsArray', true);
        fjord_shape.X = {fjord_shape.X};
        fjord_shape.Y = {fjord_shape.Y};
         % remove NaN (codes for closed polygon in GIS programs etc)
        for i=1:height(fjord_shape)
            nan_index = find(isnan(fjord_shape.X{i}));
            fjord_shape.X{i}(nan_index) = [];
            fjord_shape.Y{i}(nan_index) = [];
        end
    end

    
end