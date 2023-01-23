function master = stack2master(stack_struct, condition_struct, save_as, fjord_shape, ice_levelset_domain_path)
    ice_domain = load_ice_domain_from_shape(ice_levelset_domain_path);
    combined_stack = combine_stacks(stack_struct, condition_struct);
    stack = connect_stack2master_shape(combined_stack, fjord_shape, 'fjord');
    master = connect_stack2master_shape(stack, ice_domain, 'ice_levelset');

    % remove duplicate dates
    size(master)
    [~, w] = unique(master.Date, 'stable');
    duplicate_indices = setdiff( 1:numel(master.Date), w );
    master(duplicate_indices, :) = [];
    size(master)
    % % sort by date
    % [~, ind] = sort(datetime(master.Date(:)));
    % master = stack(ind, :);

    has_geometry = any(string(master.Properties.VariableNames) == "Geometry");
    if ~has_geometry
        master.Geometry = repmat("Polygon", height(master), 1);
    end
    master = table2struct(master);
    shapewrite(master, save_as);
end