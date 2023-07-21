md = loadmodel("Results/budd_fc_extrap_deg4-09-Jul-2023/KG_transient.mat");

% md13 = loadmodel("Results/budd_fc_extrap_tf13-09-Jul-2023/KG_transient.mat");
% md14 = loadmodel("Results/budd_fc_extrap_tf14-09-Jul-2023/KG_transient.mat");
% md16 = loadmodel("Results/budd_fc_extrap_tf16-09-Jul-2023/KG_transient.mat");
% md17 = loadmodel("Results/budd_fc_extrap_tf17-09-Jul-2023/KG_transient.mat");
% md18 = loadmodel("Results/budd_fc_extrap_tf18-09-Jul-2023/KG_transient.mat");

% mdgf1 = loadmodel("Results/budd_gf_1-20-Jun-2023/KG_transient.mat");
% mdgf2 = loadmodel("Results/budd_gf_2-20-Jun-2023/KG_transient.mat");
% mdgf3 = loadmodel("Results/budd_gf_3-20-Jun-2023/KG_transient.mat");
% mdgf4 = loadmodel("Results/budd_gf_4-20-Jun-2023/KG_transient.mat");
% mdgf5 = loadmodel("Results/budd_gf_5-20-Jun-2023/KG_transient.mat");
mdgf6 = loadmodel("Results/budd_gf_6-20-Jun-2023/KG_transient.mat");

figure(777)
[mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs([mdgf1, mdgf2, mdgf3, mdgf4, mdgf5, mdgf6], ...
                                                                    [], ...
                                                                    ["Glen factor = 1", "Glen factor = 2", "Glen factor = 3", "Glen factor = 4", "Glen factor = 5 (ref)",  "Glen factor = 6"], ...
                                                                    false, false, false);

figure(778)
[mass_balance_curve_struct2] = mass_loss_curves_comparing_front_obs([md13, md14, md, md16, md17, md18], ...
                                                                    [], ...
                                                                    ["Extrapolation constant = 13", "Extrapolation constant = 14", "Extrapolation constant = 15 (ref)", "Extrapolation constant = 16", "Extrapolation constant = 17", "Extrapolation constant = 18"], ...
                                                                    false, false, false); 

