md1 = loadmodel('Models/KG_budd_lia.mat');
offset = 4.4:0.05:4.7;

rmse_full = NaN(size(offset));
ssim_full = NaN(size(offset));
wsd_full = NaN(size(offset));
med_full = NaN(size(offset));
sd_full = NaN(size(offset));

rmse_log = NaN(size(offset));
ssim_log = NaN(size(offset));
wsd_log = NaN(size(offset));
med_log = NaN(size(offset));
sd_log = NaN(size(offset));

rmse_fast = NaN(size(offset));
ssim_fast = NaN(size(offset));
wsd_fast = NaN(size(offset));
med_fast = NaN(size(offset));
sd_fast = NaN(size(offset));

for i=1:length(offset)
    disp(offset(i))
    config = readtable('/data/eigil/work/lia_kq/Configs/budd_plastic-14-Mar-2023-config', "TextType", "string");
    config.steps = num2str([8]);
    config.lia_friction_offset = offset(i);
    config_folder = append('/data/eigil/work/lia_kq/Configs/', 'tmp.csv');
    writetable(config, config_folder, 'Delimiter', ',', 'QuoteStrings', true);
    md2 = run_model('tmp');
    T = quantify_field_difference(md1, md1.results.StressbalanceSolution.Vel, md2.results.StressbalanceSolution.Vel, './tmp', true);

    rmse_full(i) = T.RMSE(1);
    ssim_full(i) = T.SSIM(1);
    wsd_full(i) = T.WS_DIST(1);
    med_full(i) = T.MEDIAN(1);
    sd_full(i) = T.SD(1);

    rmse_log(i) = T.RMSE(2);
    ssim_log(i) = T.SSIM(2);
    wsd_log(i) = T.WS_DIST(2);
    med_log(i) = T.MEDIAN(2);
    sd_log(i) = T.SD(2);

    rmse_fast(i) = T.RMSE(3);
    ssim_fast(i) = T.SSIM(3);
    wsd_fast(i) = T.WS_DIST(3);
    med_fast(i) = T.MEDIAN(3);
    sd_fast(i) = T.SD(3);
end

figure()
subplot(2, 5, 1)
plot(offset, rmse_full)
title('RMSE, full')

subplot(2, 5, 2)
plot(offset, ssim_full)
title('SSIM, full')

subplot(2, 5, 3)
plot(offset, wsd_full)
title('Wasserstein distance, full')

subplot(2, 5, 4)
plot(offset, med_full)
title('Median, full')

subplot(2, 5, 5)
plot(offset, sd_full)
title('Standard deviation, full')

subplot(2, 5, 6)
plot(offset, rmse_fast)
title('RMSE, fast')

subplot(2, 5, 7)
plot(offset, ssim_fast)
title('SSIM, fast')

subplot(2, 5, 8)
plot(offset, wsd_fast)
title('Wasserstein distance, fast')

subplot(2, 5, 9)
plot(offset, med_fast)
title('Median, fast')

subplot(2, 5, 10)
plot(offset, sd_fast)
title('Standard deviation, fast')