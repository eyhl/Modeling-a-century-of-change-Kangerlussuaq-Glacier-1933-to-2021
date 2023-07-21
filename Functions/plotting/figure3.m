% md = loadmodel("Results/budd_fc_extrap_deg4-09-Jul-2023/KG_transient.mat");

% md_mar = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_smb_mar-09-Jul-2023/KG_transient.mat");
% md_box = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_smb_box-09-Jul-2023/KG_transient.mat");

% md1933 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933-09-Jul-2023/KG_transient.mat");
% md1933_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_2021-09-Jul-2023/KG_transient.mat");
% md1933_1981_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_1981_2021-09-Jul-2023/KG_transient.mat");
% md1933_1966_1981_1999_2021 = loadmodel("/home/eyhli/IceModeling/work/lia_kq/Results/budd_fix1933_1966_1981_1999_2021-09-Jul-2023/KG_transient.mat");
% md1933_1966_2021 = loadmodel("Results/budd_fix1933_1966_2021-19-Jul-2023/KG_transient.mat");

figure(445)
ax1 = subplot(2,1,1);
[mass_balance_curve_struct1] = mass_loss_curves_comparing_front_obs([md, md_mar, md_box, md1933], ...
                                                                    [], ...
                                                                    ["Reference: RACMO", "MAR", "Box", "Control: 1933"], ...
                                                                        "/home/eyhli/IceModeling/work/lia_kq/", true, false); %md1, md2, md3, md_control, folder)

set(gca,'XTickLabel',[]);
set(gca,'XLabel',[]);

ax2 = subplot(2,1,2);
[mass_balance_curve_struct2] = mass_loss_curves_comparing_front_obs([md, md1933_2021, md1933_1981_2021, md1933_1966_1981_1999_2021, md1933_1966_2021], ...
                                                                    [], ...
                                                                    ["Reference", "Front observations: 1933, 2021", "Front observations: 1933, 1981, 2021", "Front observations: 1933, 1966, 1981, 1999, 2021", "Front observations: 1933, 1966, 2021"], ...
                                                                    "/home/eyhli/IceModeling/work/lia_kq/", false, false); %md1, md2, md3, md_control, folder)
                                                                    

linkaxes([ax1,ax2], 'x')
