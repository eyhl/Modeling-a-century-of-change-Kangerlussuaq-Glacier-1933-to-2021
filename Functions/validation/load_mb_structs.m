function [struct_array] = load_mb_structs(ids)
    % struct_array = NaN(size(ids));
    for i=1:length(ids)
        results_folder_name = "/data/eigil/work/lia_kq/Results/";
        id_path = fullfile(append(results_folder_name, ids(i), "*"));
        folder_id = dir(id_path);
        mb_struct = load(fullfile(folder_id.folder, folder_id.name, "mass_balance_curve_struct"));
        mb_struct = mb_struct.mass_balance_curve_struct;
        struct_array(i) = mb_struct;
    end
end