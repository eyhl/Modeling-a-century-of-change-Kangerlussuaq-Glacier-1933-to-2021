function [] = experiments()
    prefix = 'KG_';
    friction_law = "budd";
    friction_ext_offset = 15;
    glen_factor = 5;
    % copyfile('/data/eigil/work/lia_kq/Models/glen_factor/KG_budd_gf_5.mat', '/data/eigil/work/lia_kq/Models/KG_budd.mat');
    % copyfile('/data/eigil/work/lia_kq/Results/budd_default-20-Jun-2023/KG_transient.mat', '/data/eigil/work/lia_kq/Models/KG_fronts.mat');

% % ---------------------------------------------------- DEFAULT -------------------------------------------------
    % Budd w.o. initial friction tuning, large extr domain, 0 melting still:
    % id00 = "budd_default";
    % disp(id00)
    % config_file_name = create_config(id00, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

    % id01 = "schoof_default";
    % disp(id01)
    % config_file_name = create_config(id01, "schoof");
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.8;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

% ---------------------------------------------------- GLEN ENHANCEMENT FACTOR -------------------------------------------------
    % copyfile('/data/eigil/work/lia_kq/Models/glen_factor/KG_budd_gf_1.mat', '/data/eigil/work/lia_kq/Models/KG_budd.mat');

    % idgf1 = append(friction_law, "_gf_1");
    % disp(idgf1)
    % config_file_name = create_config(idgf1, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % copyfile('/data/eigil/work/lia_kq/Models/glen_factor/KG_budd_gf_2.mat', '/data/eigil/work/lia_kq/Models/KG_budd.mat');

    % idgf2 = append(friction_law, "_gf_2");
    % disp(idgf2)
    % config_file_name = create_config(idgf2, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);

    % copyfile('/data/eigil/work/lia_kq/Models/glen_factor/KG_budd_gf_3.mat', '/data/eigil/work/lia_kq/Models/KG_budd.mat');

    % idgf3 = append(friction_law, "_gf_3");
    % disp(idgf3)
    % config_file_name = create_config(idgf3, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.add_damage = 3;
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);

    % copyfile('/data/eigil/work/lia_kq/Models/glen_factor/KG_budd_gf_4.mat', '/data/eigil/work/lia_kq/Models/KG_budd.mat');

    % idgf4 = append(friction_law, "_gf_4");
    % disp(idgf4)
    % config_file_name = create_config(idgf4, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.add_damage = 4;
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);

    % copyfile('/data/eigil/work/lia_kq/Models/glen_factor/KG_budd_gf_5.mat', '/data/eigil/work/lia_kq/Models/KG_budd.mat');
    
    % idgf5 = append(friction_law, "_gf_5");
    % disp(idgf5)
    % config_file_name = create_config(idgf5, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.add_damage = 5;
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);

    % copyfile('/data/eigil/work/lia_kq/Models/glen_factor/KG_budd_gf_6.mat', '/data/eigil/work/lia_kq/Models/KG_budd.mat');

    % idgf6 = append(friction_law, "_gf_6");
    % disp(idgf6)
    % config_file_name = create_config(idgf6, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.add_damage = 6;
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);

% ---------------------------------------------------- MELTING RATE -------------------------------------------------
    % Budd w.o. initial friction tuning, large extr domain, 0 melting still:
    % id0 = append(friction_law, "_mr40");
    % disp(id0)
    % config_file_name = create_config(id0, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.lia_friction_offset = friction_ext_offset;
    % config.melting_rate = 40; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

    % id1 = append(friction_law, "_mr60");
    % disp(id1)
    % config_file_name = create_config(id1, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.lia_friction_offset = friction_ext_offset;
    % config.melting_rate = 60; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id2 = append(friction_law, "_mr80");
    % disp(id2)
    % config_file_name = create_config(id2, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 80; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id3 = append(friction_law, "_mr100");
    % disp(id3)
    % config_file_name = create_config(id3, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 100; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id4 = append(friction_law, "_mr120");
    % disp(id4)
    % config_file_name = create_config(id4, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 120; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id5 = append(friction_law, "_mr140");
    % disp(id5)
    % config_file_name = create_config(id5, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 140; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id6 = append(friction_law, "_mr160");
    % disp(id6)
    % config_file_name = create_config(id6, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 160; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id7 = append(friction_law, "_mr180");
    % disp(id7)
    % config_file_name = create_config(id7, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 180; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);  

    % id8 = append(friction_law, "_mr200");
    % disp(id8)
    % config_file_name = create_config(id8, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.melting_rate = 200; 
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);

% %% ---------------------------------------------------- FIXED FRONT -------------------------------------------------
    copyfile('/data/eigil/work/lia_kq/Models/KG_fronts.mat', '/data/eigil/work/lia_kq/Models/KG_fronts_all.mat');

    % id1 = append(friction_law, "_fix1933");
    % disp(id1)
    % config_file_name = create_config(id1, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config.control_run = true;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % recipe(config_file_name);   

    % id2 = append(friction_law, "_fix1989");
    % disp(id2)
    % config_file_name = create_config(id2, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
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
    % id3 = append(friction_law, "_fix1933_2021");
    % disp(id3)
    % config_file_name = create_config(id3, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([9, 10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % md_front = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts_all.mat']);
    % md_lia.levelset.spclevelset =  md_front.levelset.spclevelset(:, [1, length(md_front.levelset.spclevelset(end, :))]);  % first and last element
    % save('Models/KG_fronts.mat', 'md_lia', '-v7.3');
    % recipe(config_file_name);   

    % id3 = append(friction_law, "_fix1933_1981_2021");
    % disp(id3)
    % config_file_name = create_config(id3, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([9, 10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % md_front = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts_all.mat']);
    % select_years = [1, 5, length(md_front.levelset.spclevelset(end, :))]; % select 1933, 1981, 2021
    % disp(md_front.levelset.spclevelset(end, select_years))
    % md_lia.levelset.spclevelset =  md_front.levelset.spclevelset(:, select_years);  % first and last element
    % save('Models/KG_fronts.mat', 'md_lia', '-v7.3');
    % recipe(config_file_name);

    % id3 = append(friction_law, "_fix1933_1966_1981_1999_2021");
    % disp(id3)
    % config_file_name = create_config(id3, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([9, 10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % md_front = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts_all.mat']);
    % select_years = [1, 2, 5, 183, length(md_front.levelset.spclevelset(end, :))]; % select 1933, 1966, 1981, 1999, 2021
    % disp(md_front.levelset.spclevelset(end, select_years))
    % md_lia.levelset.spclevelset =  md_front.levelset.spclevelset(:, select_years);  % first and last element
    % save('Models/KG_fronts.mat', 'md_lia', '-v7.3');
    % recipe(config_file_name);


    id3 = append(friction_law, "_fix1933_1966_2021");
    disp(id3)
    config_file_name = create_config(id3, friction_law);
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.steps = num2str([9, 10]);
    config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    md_front = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts_all.mat']);
    select_years = [1, 2, length(md_front.levelset.spclevelset(end, :))]; % select 1933, 1981, 2021
    disp(md_front.levelset.spclevelset(end, select_years))
    md_lia.levelset.spclevelset =  md_front.levelset.spclevelset(:, select_years);  % first and last element
    save('Models/KG_fronts.mat', 'md_lia', '-v7.3');
    recipe(config_file_name);


    copyfile('/data/eigil/work/lia_kq/Models/KG_fronts_all.mat', '/data/eigil/work/lia_kq/Models/KG_fronts.mat');


    % % ---------------------------------------------------- FRICTION EXTRAPOLATION METHOD -------------------------------------------------
    % id3 = append(friction_law, "_fc_extrap_deg1");
    % disp(id3)
    % config_file_name = create_config(id3, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = friction_ext_offset;
    % config.polynomial_order = 1;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);   

    % id4 = append(friction_law, "_fc_extrap_deg3");
    % disp(id4)
    % config_file_name = create_config(id4, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = friction_ext_offset;
    % config.polynomial_order = 3;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);   

    % id5 = append(friction_law, "_fc_extrap_deg4");
    % disp(id5)
    % config_file_name = create_config(id5, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = friction_ext_offset; %% CHANGE???
    % config.polynomial_order = 4;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);  

    % % ------------------------------------------------- FRICTION EXTRAPOLATION TUNING FACTOR ----------------------------------------------
    % id3 = append(friction_law, "_fc_extrap_tf13");
    % disp(id3)
    % config_file_name = create_config(id3, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 13;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);   

    % id4 = append(friction_law, "_fc_extrap_tf14");
    % disp(id4)
    % config_file_name = create_config(id4, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 14;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);   

    % id5 = append(friction_law, "_fc_extrap_tf16");
    % disp(id5)
    % config_file_name = create_config(id5, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 16;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);  

    % id6 = append(friction_law, "_fc_extrap_tf17");
    % disp(id6)
    % config_file_name = create_config(id6, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 17;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);  

    % id7 = append(friction_law, "_fc_extrap_tf18");
    % disp(id7)
    % config_file_name = create_config(id7, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 18;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);

    % id7 = append(friction_law, "_fc_extrap_tf2.10");
    % disp(id7)
    % config_file_name = create_config(id7, friction_law);
    % config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    % config.steps = num2str([7, 8, 9, 10]);
    % config.lia_friction_offset = 1.80;
    % config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    % writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    % % edit front observations, if KG_fronts.mat exist run_model will load front from that.
    % recipe(config_file_name);

    % ---------------------------------------------------- SMB -------------------------------------------------
    id8 = append(friction_law, "_smb_mar");
    disp(id8)
    config_file_name = create_config(id8, friction_law);
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.steps = num2str([7, 8, 9, 10]);
    config.lia_friction_offset = friction_ext_offset;
    config.smb_name = "mar";
    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    recipe(config_file_name);

    id8 = append(friction_law, "_smb_box");
    disp(id8)
    config_file_name = create_config(id8, friction_law);
    config = readtable(append('/data/eigil/work/lia_kq/Configs/', config_file_name), "TextType", "string");
    config.steps = num2str([8, 9, 10]);
    config.lia_friction_offset = friction_ext_offset;
    config.smb_name = "box";
    config_folder = append('/data/eigil/work/lia_kq/Configs/', config_file_name);
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    recipe(config_file_name);
end