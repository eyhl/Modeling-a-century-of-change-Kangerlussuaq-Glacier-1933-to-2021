function [md] = recipe(id, config_file_name)
    axes = 1.0e+06 .* [0.4167    0.4923   -2.2961   -2.2039];

    % config_file_name = create_config(id);

    md = run_model(config_file_name, false);

    results_folder_name = store_model(config_file_name);

    validate_model(results_folder_name, axes, md)
end
