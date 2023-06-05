% md = loadmodel("/data/eigil/work/lia_kq/Results/budd_default-22-May-2023/KG_transient.mat");

% md_mar = loadmodel("/data/eigil/work/lia_kq/Results/budd_smb_mar-22-May-2023/KG_transient.mat");
% md_box = loadmodel("/data/eigil/work/lia_kq/Results/budd_smb_box-22-May-2023/KG_transient.mat");

% md1900 = loadmodel("/data/eigil/work/lia_kq/Results/budd_fix1900-22-May-2023/KG_transient.mat");
% md1900_2021 = loadmodel("/data/eigil/work/lia_kq/Results/budd_fix1900_2021-22-May-2023/KG_transient.mat");
% md1900_1966_2021 = loadmodel("/data/eigil/work/lia_kq/Results/budd_fix1900_1966_2021-22-May-2023/KG_transient.mat");
figure(445)
% [mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs([mdb, mds], [], ["Schoof friction law", "Budd friction law"], false, true, false); %md1, md2, md3, md_control, folder)
[mass_balance_curve_struct1] = mass_loss_curves_comparing_front_obs([md, md_mar, md_box, md1900, md1900_2021, md1900_1966_2021], ...
                                                                    [], ...
                                                                    ["Reference: RACMO", "MAR", "Box", "Control: 1933", "Front observations: 1933, 2021", "Front observations: 1933, 1966, 2021"], ...
                                                                    false, true, false); %md1, md2, md3, md_control, folder)
% xlabel([])
% xticklabels([])