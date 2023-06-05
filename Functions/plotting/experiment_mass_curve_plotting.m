% mdb = loadmodel("/data/eigil/work/lia_kq/Results/budd_default-22-May-2023/KG_transient.mat");
% mds = loadmodel("/data/eigil/work/lia_kq/Results/schoof_default-ss1-1-medDomain-06-May-2023/KG_transient.mat");

% md_mar = loadmodel("/data/eigil/work/lia_kq/Results/budd_smb_mar-22-May-2023/KG_transient.mat");
% md_box = loadmodel("/data/eigil/work/lia_kq/Results/budd_smb_box-22-May-2023/KG_transient.mat");

% md1900 = loadmodel("/data/eigil/work/lia_kq/Results/budd_fix1900-22-May-2023/KG_transient.mat");
% md1989 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fix1989-07-May-2023/KG_transient.mat");
% md1900_2021 = loadmodel("/data/eigil/work/lia_kq/Results/budd_fix1900_2021-22-May-2023/KG_transient.mat");
% md1900_1966_2021 = loadmodel("/data/eigil/work/lia_kq/Results/budd_fix1900_1966_2021-22-May-2023/KG_transient.mat");
% figure(445)
% subplot(2,2,1)
% % [mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs([mdb, mds], [], ["Schoof friction law", "Budd friction law"], false, true, false); %md1, md2, md3, md_control, folder)
% [mass_balance_curve_struct1] = mass_loss_curves_comparing_front_obs([mds], [], ["Schoof friction law"], false, true, false); %md1, md2, md3, md_control, folder)
% % xlabel([])
% % xticklabels([])


% subplot(2,2,2)
% [mass_balance_curve_struct2] = mass_loss_curves_comparing_front_obs([mds, md1900, md1989, md1900_2021, md1900_1966_2021], ...
%                                                                     [], ...
%                                                                     ["Reference", "Control: 1900", "Control: 1989", "Front observations: 1900, 2021", ...
%                                                                     "Front observations: 1900, 1966, 2021"], ...
%                                                                     false, false, false); %md1, md2, md3, md_control, folder)
% clear md1900 md1989 md1900_2021 md1900_1966_2021;

% % % basal melting rate
% md40 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_mr40-07-May-2023/KG_transient.mat");
% md60 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_mr60-07-May-2023/KG_transient.mat");
% md80 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_mr80-07-May-2023/KG_transient.mat");
% md100 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_mr100-07-May-2023/KG_transient.mat");
% md120 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_mr120-07-May-2023/KG_transient.mat");
% md160 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_mr160-07-May-2023/KG_transient.mat");
% md180 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_mr180-07-May-2023/KG_transient.mat");
% md200 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_mr200-07-May-2023/KG_transient.mat");
% subplot(2,2,3)
% [mass_balance_curve_struct3] = mass_loss_curves_comparing_front_obs([mds, md40, md60, md80, md100, md120, md160, md180, md200], ...
%                                                                     [], ...
%                                                                     ["Reference", "40 [m/yr]", "60 [m/yr]", "80 [m/yr]", "100 [m/yr]", "120 [m/yr]", "160 [m/yr]", "180 [m/yr]", "200 [m/yr]"], ...
%                                                                     false, false, false);
% clear md40 md60 md80 md100 md120 md160 md180 md200;

%% SMB
% subplot(2,2,3)
% [mass_balance_curve_struct3] = mass_loss_curves_comparing_front_obs([mdb, md_mar, md_box, md1900, md1900_2021, md1900_1966_2021], ...
%                                                                     [], ...
%                                                                     ["Reference: RACMO", "MAR", "Box", "Control: 1933", "Front observations: 1933, 2021", "Front observations: 1933, 1966, 2021"], ...
%                                                                     false, false, false);

% md1_20 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fc_extrap_tf1.20-07-May-2023/KG_transient.mat");
% md1_30 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fc_extrap_tf1.30-07-May-2023/KG_transient.mat");
% md1_40 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fc_extrap_tf1.40-07-May-2023/KG_transient.mat");
% md1_60 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fc_extrap_tf1.60-07-May-2023/KG_transient.mat");
% md1_70 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fc_extrap_tf1.70-08-May-2023/KG_transient.mat");
% md1_80 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fc_extrap_tf1.80-08-May-2023/KG_transient.mat");

% subplot(2,2,4)
% [mass_balance_curve_struct4] = mass_loss_curves_comparing_front_obs([mds, md1_20, md1_30, md1_40, md1_60, md1_70, md1_80], ...
%                                                                     [], ...
%                                                                     ["Reference, 1.50", "1.20", "1.30", "1.40", "1.60", "1.70", "1.80"], ...
%                                                                     false, false, false);

% clear md1_20 md1_30 md1_40 md1_60 md1_70 md1_80;

% md220 = loadmodel('Results/budd_fc_extrap_tf2.20-25-May-2023/KG_transient.mat');
% md260 = loadmodel('Results/budd_fc_extrap_tf2.60-25-May-2023/KG_transient.mat');
% md280 = loadmodel('Results/budd_fc_extrap_tf2.80-25-May-2023/KG_transient.mat');
% md300 = loadmodel('Results/budd_fc_extrap_tf3.00-25-May-2023/KG_transient.mat');
% md320 = loadmodel('Results/budd_fc_extrap_tf3.20-25-May-2023/KG_transient.mat');

% figure2_plot(md220, 3)
% figure2_plot(md260, 3)
figure2_plot(md280, 3)
% figure2_plot(md300, 3)
% figure2_plot(md320, 3)



