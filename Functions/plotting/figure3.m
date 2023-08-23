% md = loadmodel("Results/budd_fc_extrap_deg4-09-Jul-2023/KG_transient.mat");

% md_mar = loadmodel("Results/budd_smb_mar-09-Jul-2023/KG_transient.mat");
% md_box = loadmodel("Results/budd_smb_box-09-Jul-2023/KG_transient.mat");

% md1933 = loadmodel("Results/budd_fix1933-09-Jul-2023/KG_transient.mat");
% md1933_2021 = loadmodel("Results/budd_fix1933_2021-09-Jul-2023/KG_transient.mat");
% md1933_1981_2021 = loadmodel("Results/budd_fix1933_1981_2021-09-Jul-2023/KG_transient.mat");
% md1933_1966_1981_1999_2021 = loadmodel("Results/budd_fix1933_1966_1981_1999_2021-09-Jul-2023/KG_transient.mat");
% md1933_1966_2021 = loadmodel("Results/budd_fix1933_1966_2021-19-Jul-2023/KG_transient.mat");

figure(445)
ax1 = subplot(4,1,1);
[mass_balance_curve_struct1, CM, leg_names] = mass_loss_curves_comparing_front_obs([md, md_mar, md_box, md1933], ...
                                                                    [], ...
                                                                    ["Reference: RACMO", "MAR", "Box", "Control: 1933"], ...
                                                                        "/home/eyhli/IceModeling/work/lia_kq/", false, false); %md1, md2, md3, md_control, folder)

set(gca,'XTickLabel',[]);
set(gca,'XLabel',[]);

ax2 = subplot(4,1,2);
plot_bar_differences([md, md_mar, md_box, md1933], CM, leg_names, 440)
set(gca,'XTickLabel',[]);
set(gca,'XLabel',[]);

ax3 = subplot(4,1,3);
[mass_balance_curve_struct2, CM, leg_names] = mass_loss_curves_comparing_front_obs([md, md1933_2021, md1933_1981_2021, md1933_1966_1981_1999_2021, md1933_1966_2021], ...
                                                                    [], ...
                                                                    ["Reference", "Front obs.: 1933, 2021", "Front obs.: 1933, 1981, 2021", "Front obs.: 1933, 1966, 1981, 1999, 2021", "Front obs.: 1933, 1966, 2021"], ...
                                                                    "/home/eyhli/IceModeling/work/lia_kq/", false, false); %md1, md2, md3, md_control, folder)

set(gca,'XTickLabel',[]);
set(gca,'XLabel',[]);
                                                                    

ax4 = subplot(4,1,4);
plot_bar_differences([md, md1933_2021, md1933_1981_2021, md1933_1966_1981_1999_2021, md1933_1966_2021], CM, leg_names, 380)
linkaxes([ax1,ax2, ax3, ax4], 'x')
set(gcf,'PaperType','A4', 'PaperOrientation', 'portrait');


