function [] = mass_loss_curves(md_list, md_control_list, md_names, folder, present_thickness) %md1, md2, md3, md_control, folder)
    save_path = folder;
    plot_smb = false;
    N = length(md_list);
    CM = parula(2*N);
    if N > 1
        CM = CM(2:4, :);
    end
    % dt = 1/12;
    % start_time = md_list(1).smb.mass_balance(end, 1);
    % final_time = md_list(1).smb.mass_balance(end, end);
    marker_control = {':', '--', '-.'};
    final_mass_loss = integrate_field_spatially(md_list(1), md_list(1).geometry.thickness - present_thickness) / (1e9) * 0.9167
    figure(111)
    for i=1:N
        md = md_list(i);
    
        %% Volume plot 1
        vol1 = cell2mat({md.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
        vol_times1 = cell2mat({md.results.TransientSolution(:).time});

        plot(vol_times1, vol1 - vol1(1), 'color', CM(i,:), 'LineWidth', 3.5);
        hold on;

        if length(md_control_list) ~= 0
            plot(vol_times_c, vol_c - vol_c(1), 'color', CM(i,:), 'LineWidth', 3.5, 'LineStyle', marker_control{i});
            % scatter(vol_times_c, vol_c - vol_c(1), 'color', CM(i,:), 'Marker', marker_control{i});
                
            %% Volume plot CONTROL
            md_control = md_control_list(i);
            vol_c = cell2mat({md_control.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
            vol_times_c = cell2mat({md_control.results.TransientSolution(:).time});
        end
    end
    if plot_smb
        %% Volume plot CONTROL
        smb = cell2mat({md_list(1).results.TransientSolution(:).TotalSmb}) * 1e-12 * md_list(1).constants.yts; % from kg s^-1 to Gt/yr
        smb_times = cell2mat({md_list(1).results.TransientSolution(:).time});
        dt = diff(smb_times);
        dt = [dt dt(end)]; % duplicate last time step as simple padding;        
        cumulative_smb = dt .* cumtrapz(smb);
        dt_avg = mean(dt);
        mov_window = int8(3 / dt_avg); % window over 3 years
        plot(smb_times, cumulative_smb, 'color', 'k', 'LineWidth', 1.5);  % dt=1/12
    end
    % scatter(vol_times_c(end), final_mass_loss, 'r');
    xlabel('Year')
    ylabel('Mass [Gt]')
    xlim([1897, 2023])
    set(gca,'fontsize', 18)
    % ylim([-400, 1000])
    legend(md_names, 'Location', 'southwest')
    grid on

    exportgraphics(gcf, fullfile(save_path, 'ice_volume_comparison.png'), 'Resolution', 300)
end