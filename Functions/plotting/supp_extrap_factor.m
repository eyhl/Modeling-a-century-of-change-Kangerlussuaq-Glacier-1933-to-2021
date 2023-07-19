% md = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fc_extrap_deg4-09-Jul-2023/KG_transient.mat");

% md_mar = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_smb_mar-09-Jul-2023/KG_transient.mat");
% md_box = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_smb_box-09-Jul-2023/KG_transient.mat");

% md1900 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933-09-Jul-2023/KG_transient.mat");
% md1900_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_2021-09-Jul-2023/KG_transient.mat");
% md1900_1981_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_1981_2021-09-Jul-2023/KG_transient.mat");
% md1933_1966_1981_1999_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_1966_1981_1999_2021-09-Jul-2023/KG_transient.mat");

% md13 = loadmodel("Results/budd_fc_extrap_tf13-09-Jul-2023/KG_transient.mat");
% md14 = loadmodel("Results/budd_fc_extrap_tf14-09-Jul-2023/KG_transient.mat");
% md16 = loadmodel("Results/budd_fc_extrap_tf16-09-Jul-2023/KG_transient.mat");
% md17 = loadmodel("Results/budd_fc_extrap_tf17-09-Jul-2023/KG_transient.mat");
% md18 = loadmodel("Results/budd_fc_extrap_tf18-09-Jul-2023/KG_transient.mat");

% [mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs([mdb, mds], [], ["Schoof friction law", "Budd friction law"], false, true, false); %md1, md2, md3, md_control, folder)
[mass_balance_curve_struct2] = mass_loss_curves_comparing_front_obs([md13, md14, md, md17, md18], ...
                                                                    [], ...
                                                                    ["13", "14", "15", "17", "18"], ...
                                                                    false, false, false); %md1, md2, md3, md_control, folder)
% [mass_balance_curve_struct1] = mass_loss_curves_comparing_front_obs([md, md1900, md1900_2021], ...
%                                                                     [], ...
%                                                                     ["Reference: RACMO", "Control: 1933", "Front observations: 1933, 2021"], ...
%                                                                     false, true, false); %md1, md2, md3, md_control, folder)
% xlabel([])
% xticklabels([])