function [] = experiments()
    % Budd default (dmg, vermassen collapse, bed correlation)
    % id4 = "default";
    % disp(id4)
    % config_file_name = create_config(id4, "budd");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([8, 9, 10]);
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe('default-14-Mar-2023-config');   

    % Budd plastic (dmg, vermassen collapse, bed correlation):
    id5 = "budd_plastic";
    disp(id5)
    config_file_name = create_config(id5, "budd_plastic");
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.steps = num2str([9, 10]);
    config.velocity_exponent = 5;
    config.friction_law = "budd_plastic";

    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    recipe(config_file_name);
end