function [] = experiments()
    % Budd w.o. initial friction tuning, large extr domain, 0 melting still:
    % id4 = "budd_mr20";
    % disp(id4)
    % config_file_name = create_config(id4, "budd");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([8, 9, 10]);
    % config.lia_friction_offset = 1.8;

    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

    % Schoof w.o. initial friction tuning, large extr domain, 0 melting still:
    id5 = "schoof_1880_lia_surf";
    disp(id5)
    config_file_name = create_config(id5, "schoof");
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.steps = num2str([8, 9, 10]);
    config.lia_friction_offset = 0;
    config.start_time = 1880;
    config.friction_extrapolation = "bed_correlation";

    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    recipe(config_file_name);
end