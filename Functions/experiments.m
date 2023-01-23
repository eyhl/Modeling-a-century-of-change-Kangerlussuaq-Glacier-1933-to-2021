function [] = experiments()
    % Temperature experiments:
    id1 = "T-20.0";
    config_file_name = create_config(id1);
    config = readtable(append('Configs/', config_file_name), "TextType", "string");
    config.ice_temp_offset = -20;
    % save table
    config_folder = append('Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    [md1] = recipe(id1, config_file_name);

    id2 = "T-10.0";
    config_file_name = create_config(id2);
    config = readtable(append('Configs/', config_file_name), "TextType", "string");
    config.ice_temp_offset = -10;
    % save table
    config_folder = append('Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    [md2] = recipe(id);

    id3 = "T-5.0";
    config_file_name = create_config(id3);
    config = readtable(append('Configs/', config_file_name), "TextType", "string");
    config.ice_temp_offset = -5;
    % save table
    config_folder = append('Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    [md3] = recipe(id);

    id4 = "T-2.5";
    config_file_name = create_config(id4);
    config = readtable(append('Configs/', config_file_name), "TextType", "string");
    config.ice_temp_offset = -2.5;
    % save table
    config_folder = append('Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    [md4] = recipe(id);

    mass_balance_curve_struct = mass_loss_curves([md1, md2, md3, md4], [], [id1, id2, id3, id4], ".");
end