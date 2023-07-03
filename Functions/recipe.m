function [md] = recipe(config_file_name)
    axes = 1.0e+06 .* [0.4167    0.4923   -2.2961   -2.2039];

    % config_file_name = create_config(id);

    md = run_model(config_file_name, false);
    % md = loadmodel('/data/eigil/work/lia_kq/Results/budd_fix1900-21-Jun-2023/KG_transient.mat');
    results_folder_name = store_model(config_file_name);

    validate_model(results_folder_name, axes, md)
end
