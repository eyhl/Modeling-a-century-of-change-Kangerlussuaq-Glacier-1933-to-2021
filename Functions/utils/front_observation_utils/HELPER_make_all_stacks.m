function [s1, s2] = HELPER_make_all_stacks(fjord_path)
    % get paths
    ice_path = "/data/eigil/work/lia_kq/Data/shape/icelevelset_domain/domain.shp";
    [autoterm_path, calfin_path, historic_path] = HELPER_get_file_paths_KG();
    if nargin < 1
        fjord_shape = get_fjord_shape(calfin_path, 'find');
    else
        fjord_shape = get_fjord_shape(fjord_path, 'load');
    end
    % get various stacks
    historic_stack = get_historic_KG_stack(historic_path);
    calfin_stack = get_calfin_stack(calfin_path);
    autoterm_stack = get_autoterm_stack(autoterm_path, fjord_shape);

    % get filtering conditions
    cond_historic = get_date_condition(historic_stack, '<=', datetime(1982, 1, 1));
    cond_autoterm = get_date_condition(autoterm_stack);
    cond_calfin = get_date_condition(calfin_stack);

    % autoterm historic
    stack_struct = {historic_stack, autoterm_stack};
    cond_struct = {cond_historic, cond_autoterm};
    s1 = stack2master(stack_struct, cond_struct, 'autoterm_historic', fjord_shape, ice_path);

    % calfin historic
    stack_struct = {historic_stack, calfin_stack};
    cond_struct = {cond_historic, cond_calfin};
    s2 = stack2master(stack_struct, cond_struct, 'calfin_historic', fjord_shape, ice_path);

    % calfin historic
    stack_struct = {historic_stack, calfin_stack, autoterm_stack};
    cond_struct = {cond_historic, cond_calfin, cond_autoterm};
    s3 = stack2master(stack_struct, cond_struct, 'calfin_historic', fjord_shape, ice_path);
end