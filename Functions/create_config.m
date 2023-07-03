function [config_file_name] = create_config(id, friction_law)
    friction_law = string(friction_law);
    todays_date = datetime('now');
    todays_date = string(dateshift(todays_date, 'start', 'day'));

    if nargin < 1
        id = todays_date;
    else
        id = append(id, '-', todays_date);
    end
    % identifyer
    glacier_name = "KG";
    front_observation_path = "/data/eigil/work/lia_kq/Data/shape/fronts/processed/vermassen.shp";

    % Set parameters
    steps = [1, 2, 3]; % 3=budd, 6=schoof
    start_time = 1933.58;
    final_time = 2021;
    ice_temp_offset = 0; % C
    lia_friction_offset = 15;
    output_frequency = 4; % output frequency for transient run
    velocity_exponent = 1;
    melting_rate = 20;

    if strcmp(friction_law, 'budd')
        % Inversion parameters
        cf_weights = [14000,3,2.5783e-06]; % [16000, 3.0,  1.7783e-06];
        cs_min = 0.01;
        cs_max = 1e4;
    elseif strcmp(friction_law, 'budd_plastic')
        % Inversion parameters
        cf_weights = [300, .16, 1.30e-5];
        velocity_exponent = 5;
        cs_min = 1e-10;
        cs_max = 200;
    elseif strcmp(friction_law, 'regcoulomb')
        cf_weights = [16000, 3.0,  1.7783e-06];
        cs_min = 0.01;
        cs_max = 1e4;
    elseif strcmp(friction_law, 'schoof')
        % cf_weights = [2500, 16.0, 4.0e-08, 0.811428571428571]; % from before damage was added.
        % cf_weights = [300, 0.8, 1.3e-10, 0.8114]; % before 5 april
        cf_weights = [300, 1.0, 1.1e-10, 0.7115]; % % after april 6
        cs_min = 5; % 0.01;
        cs_max = 5800; % 1e4;
    elseif strcmp(friction_law, 'weertman')
        cf_weights = [16000, 2.0,  7.5e-08];
        cs_min = 0.01;
        cs_max = 1e4;
    else
        disp('Friction law not implemented')
    end
    % Relevant data paths
    add_damage = 5;
    smb_name = "racmo";
    friction_extrapolation = "bed_correlation"; % or semi-variogram
    polynomial_order = 4;
    steps = strjoin(string(steps));

    control_run = false;

    % create table
    config = table(todays_date, steps, start_time, final_time, output_frequency, ...
                   ice_temp_offset, lia_friction_offset, cf_weights, cs_min, cs_max, ...
                   velocity_exponent, add_damage, melting_rate, smb_name, ...
                   friction_extrapolation, friction_law, polynomial_order, glacier_name, control_run, ...
                   front_observation_path);

    % save table
    config_file_name = append(id, '-config', '.csv');
    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);

    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
end


%     % cf_weights = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3]; %TODO: CHANGE THIS 
%    % BUDD COEFFICIENTS
%     % budd_coeff = [16000, 3.0,  1.7783e-06]; % newest: [16000, 3.0,  1.7783e-06];% v8 [8000, 1.75, 4.1246e-07]; % v7 [4000, 2.75, 3.2375e-05]; % v6 [4000, 2.75, 1.5264e-07];
%     % budd_coeff = [16000, 3.0,  1e-07]; % newest: [16000, 3.0,  1.7783e-06];% v8 [8000, 1.75, 4.1246e-07]; % v7 [4000, 2.75, 3.2375e-05]; % v6 [4000, 2.75, 1.5264e-07];
%     % budd_coeff = [8000, 3.0,  5.6234e-06]; 
%     % budd_coeff = [8000, 3.0,  1e-05]; 

%     % try both:
%     budd_coeff = [16000, 3.0,  1.7783e-06]; <-
%     % budd_coeff = [8000, 3.0,  1.7783e-05]; 

%     % SCHOOF COEFFICIENTS
%     schoof_coeff = [2500, 16.0, 4.0e-08, 0.811428571428571]; % [4000, 2.25, 3.4551e-08, 0.667] v2 [4000, 2.2, 2.5595e-08, 0.667]; <-
%     % schoof_coeff = [2500, 300.0, 7.5e-08, 0.811428571428571]; % [4000, 2.25, 3.4551e-08, 0.667] v2 [4000, 2.2, 2.5595e-08, 0.667];
%     % schoof_coeff = [2500, 2.0, 1e-07, 0.74]; % [4000, 2.25, 3.4551e-08, 0.667] v2 [4000, 2.2, 2.5595e-08, 0.667];

%     % WEERTMAND COEFFICIENTS
%     % weertman_coeff = [16000, 2.0,  7.5e-08];
%     weertman_coeff = [16000, 2.0,  7.5e-08]; <-