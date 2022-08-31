function [] = compare_models(md1, md2, folder)
    close all;
    save_path = folder;
    
    dt = 1/12;
    start_time = md1.smb.mass_balance(end, 1);
    final_time = md1.smb.mass_balance(end, end);

    %% Volume plot
    vol1 = cell2mat({md1.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
    vol_times1 = cell2mat({md1.results.TransientSolution(:).time});

    %% Volume plot
    vol2 = cell2mat({md2.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
    vol_times2 = cell2mat({md2.results.TransientSolution(:).time});

    figure(1);
    plot(vol_times1, vol1 - vol1(1), '-k', 'LineWidth', 1);
    hold on
    plot(vol_times2, vol2 - vol1(1), '-r', 'LineWidth', 1);

    % title('Modelled Relative Ice Loss (RACMO SMB)')
    ylabel('Year')
    ylabel('Mass [Gt]')
    xlim([1897, 2023])
    legend('Moving ice front', 'Static ice front', 'Location', 'southwest')
    grid on
    % ylim([2.32e4 2.48e4])
    exportgraphics(gcf, fullfile(save_path, 'ice_volume_comparison.png'), 'Resolution', 500)