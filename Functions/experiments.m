function [] = experiments()
    prefix = 'KG_';

% % ---------------------------------------------------- DEFAULT -------------------------------------------------
    % Budd w.o. initial friction tuning, large extr domain, 0 melting still:
    % id00 = "budd_default";
    % disp(id00)
    % config_file_name = create_config(id00, "budd");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([8, 9, 10]);
    % config.lia_friction_offset = 1.8; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

    % id01 = "schoof_default";
    % disp(id01)
    % config_file_name = create_config(id01, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([8, 9, 10]);
    % config.lia_friction_offset = 1.5;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

% ---------------------------------------------------- MELTING RATE -------------------------------------------------
    %% Budd w.o. initial friction tuning, large extr domain, 0 melting still:
    % id0 = "schoof_mr40";
    % disp(id0)
    % config_file_name = create_config(id0, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.lia_friction_offset = 1.5;
    % config.melting_rate = 40; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

    % id1 = "schoof_mr60";
    % disp(id1)
    % config_file_name = create_config(id1, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.lia_friction_offset = 1.5;
    % config.melting_rate = 60; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id2 = "schoof_mr80";
    % disp(id2)
    % config_file_name = create_config(id2, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 80; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id3 = "schoof_mr100";
    % disp(id3)
    % config_file_name = create_config(id3, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 100; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id4 = "schoof_mr120";
    % disp(id4)
    % config_file_name = create_config(id4, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 120; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id5 = "schoof_mr140";
    % disp(id5)
    % config_file_name = create_config(id5, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 140; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id6 = "schoof_mr160";
    % disp(id6)
    % config_file_name = create_config(id6, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 160; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id7 = "schoof_mr180";
    % disp(id7)
    % config_file_name = create_config(id7, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 180; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id8 = "schoof_mr200";
    % disp(id8)
    % config_file_name = create_config(id8, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 200; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);

%% ---------------------------------------------------- FIXED FRONT -------------------------------------------------
    % copyfile('/data/eigil/work/lia_kq/Models/KG_fronts.mat', '/data/eigil/work/lia_kq/Models/KG_fronts_all.mat');

    % id1 = "schoof_fix1900";
    % disp(id1)
    % config_file_name = create_config(id1, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.lia_friction_offset = 1.5; %% CHANGE???
    % config.control_run = true;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

    % id2 = "schoof_fix1989";
    % disp(id2)
    % config_file_name = create_config(id2, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.5; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % md_front = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts_all.mat']);
    % md_lia = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'lia.mat']);
    % select_years = md_front.levelset.spclevelset(end, :) < 1990;
    % md_lia.levelset.spclevelset =  md_front.levelset.spclevelset(:, select_years);
    % save('Models/KG_fronts.mat', 'md_lia', '-v7.3');
    % recipe(config_file_name);   

% % ---------------------------------------------------- SEASONALITY -------------------------------------------------
    % id3 = "schoof_fix1900_2021";
    % disp(id3)
    % config_file_name = create_config(id3, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([9, 10]);
    % config.lia_friction_offset = 1.5; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % md_front = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts_all.mat']);
    % md_lia.levelset.spclevelset =  md_front.levelset.spclevelset(:, [1, length(md_front.levelset.spclevelset(end, :))]);  % first and last element
    % save('Models/KG_fronts.mat', 'md_lia', '-v7.3');
    % recipe(config_file_name);   

    % id3 = "schoof_fix1900_1966_2021";
    % disp(id3)
    % config_file_name = create_config(id3, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([9, 10]);
    % config.lia_friction_offset = 1.5; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % md_front = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts_all.mat']);
    % select_years = find(md_front.levelset.spclevelset(end, :) > 1965 & md_front.levelset.spclevelset(end, :) < 1967); % find 1966
    % select_years = [1, select_years, length(md_front.levelset.spclevelset(end, :))]; % select 1900, 1966, 2021
    % disp(md_front.levelset.spclevelset(end, select_years))
    % md_lia.levelset.spclevelset =  md_front.levelset.spclevelset(:, select_years);  % first and last element
    % save('Models/KG_fronts.mat', 'md_lia', '-v7.3');
    % recipe(config_file_name);
    % copyfile('/data/eigil/work/lia_kq/Models/KG_fronts_all.mat', '/data/eigil/work/lia_kq/Models/KG_fronts.mat');


    % % ---------------------------------------------------- FRICTION EXTRAPOLATION METHOD -------------------------------------------------
    % id3 = "schoof_fc_extrap_deg1";
    % disp(id3)
    % config_file_name = create_config(id3, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.5;
    % config.polynomial_order = 1;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);   

    % id4 = "schoof_fc_extrap_deg3";
    % disp(id4)
    % config_file_name = create_config(id4, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.5;
    % config.polynomial_order = 3;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);   

    % id5 = "schoof_fc_extrap_deg4";
    % disp(id5)
    % config_file_name = create_config(id5, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.5; %% CHANGE???
    % config.polynomial_order = 4;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);  

    % % ------------------------------------------------- FRICTION EXTRAPOLATION TUNING FACTOR ----------------------------------------------
    % id3 = "schoof_fc_extrap_tf1.20";
    % disp(id3)
    % config_file_name = create_config(id3, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.20;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);   

    % id4 = "schoof_fc_extrap_tf1.30";
    % disp(id4)
    % config_file_name = create_config(id4, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.30;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);   

    % id5 = "schoof_fc_extrap_tf1.40";
    % disp(id5)
    % config_file_name = create_config(id5, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.40;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);  

    % id6 = "schoof_fc_extrap_tf1.60";
    % disp(id6)
    % config_file_name = create_config(id6, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.60;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);  

    % id7 = "schoof_fc_extrap_tf1.70";
    % disp(id7)
    % config_file_name = create_config(id7, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.70;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);

    % id7 = "schoof_fc_extrap_tf1.80";
    % disp(id7)
    % config_file_name = create_config(id7, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.80;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);

    % ---------------------------------------------------- SMB -------------------------------------------------
    id8 = "schoof_smb_mar";
    disp(id8)
    config_file_name = create_config(id8, "schoof");
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.steps = num2str([7, 8, 9, 10]);
    config.lia_friction_offset = 1.50;
    config.smb_name = "mar";
    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    recipe(config_file_name);

    id8 = "schoof_smb_box";
    disp(id8)
    config_file_name = create_config(id8, "schoof");
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.steps = num2str([8, 9, 10]);
    config.lia_friction_offset = 1.50;
    config.smb_name = "box";
    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    recipe(config_file_name);
end