function [] = HELPER_make_all_stacks()
    % get paths
    ice_path = "/data/eigil/work/lia_kq/Data/shape/icelevelset_domain/domain.shp";
    [autoterm_path, calfin_path, historic_path] = HELPER_get_file_paths_KG();
    fjord_shape = get_fjord_shape(calfin_path, 'find');

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
    stack2master(stack_struct, cond_struct, 'autoterm_historic', fjord_shape, ice_path);

    % calfin historic
    stack_struct = {historic_stack, calfin_stack};
    cond_struct = {cond_historic, cond_calfin};
    stack2master(stack_struct, cond_struct, 'calfin_historic', fjord_shape, ice_path);
end