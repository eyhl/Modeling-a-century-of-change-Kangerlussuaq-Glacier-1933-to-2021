% mdb = loadmodel("/data/eigil/work/lia_kq/Results/budd_default-14-Apr-2023/KG_transient.mat");
% mds = loadmodel("/data/eigil/work/lia_kq/Results/schoof_default-12-Apr-2023/KG_transient.mat");

% md1900 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fix1900-13-Apr-2023/KG_transient.mat");
% md1989 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fix1989-13-Apr-2023/KG_transient.mat");
% md1900_2021 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fix1900_2021-13-Apr-2023/KG_transient.mat");
% md1900_1966_2021 = loadmodel("/data/eigil/work/lia_kq/Results/schoof_fix1900_1966_2021-13-Apr-2023/KG_transient.mat");

% % basal melting rate
% md40 = loadmodel("");
% md60 = loadmodel("");
% md80 = loadmodel("");
% md100 = loadmodel("");
% md120 = loadmodel("");
% md160 = loadmodel("");
% md200 = loadmodel("");

figure(445)
subplot(2,1,1)
[mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs([mdb, mds], [], ["Schoof friction law", "Budd friction law"], false, true, false); %md1, md2, md3, md_control, folder)
xlabel([])
xticklabels([])

subplot(2,1,2)
[mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs([mdb, md1900, md1989, md1900_2021, md1900_1966_2021], [], ["Reference", "Control: 1900", "Control: 1989", "Front observations: 1900, 2021", "Front observations: 1900, 1966, 2021"], false, false, false); %md1, md2, md3, md_control, folder)
