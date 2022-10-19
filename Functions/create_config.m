function [config_file_name] = create_config()
    % identifyer
    model_name = "kq";

    % Set parameters
    steps = [1:8];
    start_time = 1900;
    final_time = 2022;
    ice_temp = -8;

    % Inversion parameters
    cf_weights = [3000, 1.5, 5e-8]; % budd
    cs_min = 0.01;
    cs_max = 1e5;

    % Relevant data paths
    smb_name = "racmo";
    friction_extrapolation = "bed_correlation"; % or semi-variogram
    friction_law = "schoof";
    ran_steps = strjoin(string(steps));

    todays_date = datetime('now');
    todays_date.Format = 'yyyy-MM-dd''T''HHmm';              
    todays_date = string(dateshift(todays_date, 'start', 'minute'));

    % create table
    config = table(todays_date, ran_steps, start_time, final_time, ice_temp, cf_weights, cs_min, cs_max, smb_name, friction_extrapolation, friction_law, model_name);

    % save table
    config_file_name = append('config-', string(start_time), '-', string(final_time), '-D', todays_date, '.csv');
    config_folder = append('Configs/', config_file_name);

    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);

    % save table
    results_folder_name = append('Results/', todays_date);
    if ~exist(results_folder_name, 'dir')
        mkdir(results_folder_name)
    end

    results_config_name = append(results_folder_name, '/', config_file_name);
    writetable(config, results_config_name, 'Delimiter', ',', 'QuoteStrings', true);
    
end