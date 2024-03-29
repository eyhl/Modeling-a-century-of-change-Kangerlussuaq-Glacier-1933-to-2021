function [shape_table] = get_autoterm_stack(path, fjord_shape)
    %% GET_AUTOTERM_STACK() returns a shape table containing
    % the front shapes constrained to be inside the provided fjord_shape
    % fjord_shape can be any table(X, Y) coordinates dilineating the area within
    % which you would like to keep shapes. 
    % NOTE: this was designed for AutoTerm data which has noisy fronts extending
    % beyond the fjord walls. 
    shape_table = load_autoterm(path);
    if nargin >= 2
        shape_table = remove_points_outside_fjord(shape_table, fjord_shape);
    end

    % reduce since we don't need the other fields AND because autoterm has 'Lat' and 
    % 'Lon' field which messes with shapewrite. Alternatively, rename them.
    shape_table = shape_table(:, {'X', 'Y', 'Date'});
end