function [results_folder_name] = store_model(config_file_name)
    config_file_path = fullfile('Configs/', config_file_name);
    config = readtable(config_file_path, "TextType", "string");

    string_split = split(config_file_name, '.');
    id = string_split(1);
    string_split = split(id, '-');
    id = strjoin(string_split(1:end-1), '-');

    % make results directory
    results_folder_name = fullfile('Results', id);
    model_name = append(config.glacier_name, '_', 'transient.mat');
    model_file_path = fullfile('./Models', model_name);
    % if ~exist(results_folder_name, 'dir')
        mkdir(results_folder_name);
        copyfile(config_file_path, fullfile(results_folder_name, config_file_name));
        copyfile(model_file_path, fullfile(results_folder_name, model_name));
    % else
    %     user_input = input('WARNING: Folder already exists! Do you want to overwrite its contents? Press (y)es or (n)o \n', 's');
    %     if strcmp(user_input, 'y')
    %         rmdir(results_folder_name, 's');
    %         mkdir(results_folder_name);
    %         copyfile(config_file_path, fullfile(results_folder_name, config_file_name));
    %         copyfile(model_file_path, fullfile(results_folder_name, model_name));
    %     else
    %         disp('Nothing happened...');
    %     end
    % end
end