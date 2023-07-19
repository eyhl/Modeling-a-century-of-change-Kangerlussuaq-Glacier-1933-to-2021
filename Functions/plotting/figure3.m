% md = loadmodel("Results/archive/budd_default-12-May-2023/KG_transient.mat");

% md_mar = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_smb_mar-09-Jul-2023/KG_transient.mat");
% md_box = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_smb_box-09-Jul-2023/KG_transient.mat");

% md1900 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933-09-Jul-2023/KG_transient.mat");
% md1900_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_2021-09-Jul-2023/KG_transient.mat");
% md1900_1981_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_1981_2021-09-Jul-2023/KG_transient.mat");
% md1933_1966_1981_1999_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_1966_1981_1999_2021-09-Jul-2023/KG_transient.mat");

figure(445)
% [mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs([mdb, mds], [], ["Schoof friction law", "Budd friction law"], false, true, false); %md1, md2, md3, md_control, folder)
[mass_balance_curve_struct1] = mass_loss_curves_comparing_front_obs([md, md1900_2021, md1900_1981_2021, md1933_1966_1981_1999_2021, md_test], ...
                                                                    [], ...
                                                                    ["Reference", "Front observations: 1933, 2021", "Front observations: 1933, 1981, 2021", "Front observations: 1933, 1966, 1981, 1999, 2021", "Front observations: 1933, 1966, 2021"], ...
                                                                    false, true, false); %md1, md2, md3, md_control, folder)
% [mass_balance_curve_struct1] = mass_loss_curves_comparing_front_obs([md, md1900, md1900_2021], ...
%                                                                     [], ...
%                                                                     ["Reference: RACMO", "Control: 1933", "Front observations: 1933, 2021"], ...
%                                                                     false, true, false); %md1, md2, md3, md_control, folder)
% xlabel([])
% xticklabels([])