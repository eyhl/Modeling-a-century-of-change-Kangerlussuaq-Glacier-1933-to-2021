function [shape_table] = get_calfin_stack(path, fjord_shape)
    %% GET_CALFIN_STACK() returns a shape table containing
    % the front shapes constrained to be inside the provided fjord_shape
    % fjord_shape can be any [x; y] coordinates dilineating the area within
    % which you would like to keep shapes. 
    % NOTE: this was designed for AutoTerm data which has noisy fronts extending
    % beyond the fjord walls. But in general it is something we want for a "shape stack"
    shape_table = load_calfin(path);

    % We assume open shapes, so calfin shape will have to be reindexed
    shape_table = reindex_closed_shape(shape_table);

    % Remove points outside fjord_shap
    if nargin >= 2
        shape_table = remove_points_outside_fjord(shape_table, fjord_shape);
    end
end