function [] = experiments()
    % Default experiment (with new date for 1932 front, should have been 1933):
    id4 = "default";
    disp(id4)
    config_file_name = create_config(id4);
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.steps = num2str([8, 9]);
    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    recipe(config_file_name);   

    % Vermassen experiment:
    id5 = "vermassen";
    disp(id5)
    config_file_name = create_config(id5);
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.front_observation_path = "/data/eigil/work/lia_kq/vermassen.shp";
    config.steps = num2str([8, 9]);
    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    recipe(config_file_name);
end