function [] = compare_models(md1, md2, md3, md_control, folder)
    close all;
    save_path = folder;
    
    dt = 1/12;
    start_time = md1.smb.mass_balance(end, 1);
    final_time = md1.smb.mass_balance(end, end);

    sides = ContourToNodes(mesh_x, mesh_y, 'Exp/remove_sides.exp', 2);


    %% Volume plot 1
    vol1 = cell2mat({md1.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
    vol_times1 = cell2mat({md1.results.TransientSolution(:).time});

    %% Volume plot 2
    vol2 = cell2mat({md2.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
    vol_times2 = cell2mat({md2.results.TransientSolution(:).time});

    %% Volume plot 3
    vol3 = cell2mat({md3.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
    vol_times3 = cell2mat({md3.results.TransientSolution(:).time});

    %% Volume plot CONTROL
    vol_c = cell2mat({md_control.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
    vol_times_c = cell2mat({md_control.results.TransientSolution(:).time});

    figure(1);
    plot(vol_times_c, vol_c - vol_c(1), '-k', 'LineWidth', 1);
    hold on
    plot(vol_times1, vol1 - vol1(1), '-r', 'LineWidth', 1);
    plot(vol_times2, vol2 - vol2(1), '-b', 'LineWidth', 1);
    plot(vol_times3, vol3 - vol3(1), '-g', 'LineWidth', 1);

    % title('Modelled Relative Ice Loss (RACMO SMB)')
    ylabel('Year')
    ylabel('Mass [Gt]')
    xlim([1897, 2023])
    legend('Control', 'Budd', 'Schoof', 'Weertman', 'Location', 'northwest')
    grid on
    % ylim([2.32e4 2.48e4])
    exportgraphics(gcf, fullfile(save_path, 'ice_volume_comparison.png'), 'Resolution', 300)