function [] = compare_models(md_list, md_control_list, md_names, folder) %md1, md2, md3, md_control, folder)
    close all;
    save_path = folder;
    N = length(md_list);
    CM = jet(N);
    dt = 1/12;
    start_time = md1.smb.mass_balance(end, 1);
    final_time = md1.smb.mass_balance(end, end);
    figure(111)
    for i=1:N
        md = md_list(i);
        md_control = md_control_list(i);
    
        %% Volume plot 1
        vol1 = cell2mat({md.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
        vol_times1 = cell2mat({md.results.TransientSolution(:).time});
    
        %% Volume plot CONTROL
        vol_c = cell2mat({md_control.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
        vol_times_c = cell2mat({md_control.results.TransientSolution(:).time});

        plot(vol_times1, vol1 - vol1(1), 'color', CM(i,:), 'LineWidth', 2, 'LineStyle', '-');
        plot(vol_times_c, vol_c - vol_c(1), 'color', CM(i,:), 'LineWidth', 2, 'LineStyle', '-.');
    end
    ylabel('Year')
    ylabel('Mass [Gt]')
    xlim([1897, 2023])
    legend(md_names, 'Location', 'northwest')
    grid on

    % figure(111);
    % plot(vol_times_c, vol_c - vol_c(1), '-k', 'LineWidth', 1);
    % hold on
    % plot(vol_times1, vol1 - vol1(1), '-r', 'LineWidth', 1);
    % plot(vol_times2, vol2 - vol2(1), '-b', 'LineWidth', 1);
    % plot(vol_times3, vol3 - vol3(1), '-g', 'LineWidth', 1);

    % title('Modelled Relative Ice Loss (RACMO SMB)')
    
    % ylim([2.32e4 2.48e4])
    exportgraphics(gcf, fullfile(save_path, 'ice_volume_comparison.png'), 'Resolution', 300)
end