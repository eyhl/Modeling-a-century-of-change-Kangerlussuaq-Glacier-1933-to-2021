function [shape_table] = get_historic_KG_stack(path, fjord_shape)
    %% GET_HISTORIC_KG_STACK() returns a shape table containing
    % the front shapes constrained to be inside the provided fjord_shape
    % fjord_shape can be any [x; y] coordinates dilineating the area within
    % which you would like to keep shapes. 
    shape_table = load_historic_KG(path);
    % shape_table = reindex_closed_shape(shape_table);

    % NOTE: AVOID removing points outside fjord, because floating tongue extends fjord in 1900.
    if nargin >= 2
        disp('WARNING: you are probably removing floating toungue in 1900');
        shape_table = remove_points_outside_fjord(shape_table, fjord_shape);
    end
    shape_table = shape_table(:, {'X', 'Y', 'Date'});
end