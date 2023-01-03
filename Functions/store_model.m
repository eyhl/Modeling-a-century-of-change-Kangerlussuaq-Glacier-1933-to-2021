function [results_folder_name] = store_model(config_file_name)
    config = readtable(config_file_name, "TextType", "string");

    string_split = split(config_file_name, '-');
    id = string_split(1);
    
    % make results directory
    results_folder_name = fullfule('Results', id);
    model_file_path = fullfile('./Models', [config.glacier_name, '_', 'transient.mat']);
    if ~exist(results_folder_name, 'dir')
        mkdir(results_folder_name);
        copyfile(config_file_name, results_folder_name);
        copyfile(model_file_path, results_folder_name);
    end
end