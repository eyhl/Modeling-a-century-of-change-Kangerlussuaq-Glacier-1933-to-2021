function [] = experiments()
    % Front fixation experiments:
    id0 = "default";
    config_file_name = create_config(id0);
    [md0] = recipe(config_file_name);

    id1 = "fixAfter19XX";
    config_file_name = create_config(id1);
    config = readtable(append('Configs/', config_file_name), "TextType", "string");
    config.steps = 9;
    % save table
    config_folder = append('Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);

    % load KG_fronts and change spclevelset AND run step 9
    md_tmp = loadmodel("/data/eigil/work/lia_kq/Models/KG_fronts.mat");
    md.tmp = 2;
    [md1] = recipe(config_file_name);

    id2 = "fixAfter19XX";
    id3 = "fixAfter19XX";


    % mass_balance_curve_struct = mass_loss_curves([md1, md2, md3, md4, md5, md6], [], ...
    %                                         ["-8 C", "-4 C", "-2 C", "0 C", "+2 C", "+4 C"], ".");
end