function [mass_balance_curve_struct] = mass_loss_curves(md_list, md_control_list, md_names, folder) %md1, md2, md3, md_control, folder)
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
    % if nargin > 4
    %     present_thickness needs to be defined
    %     final_mass_loss = integrate_field_spatially(md_list(1), md_list(1).geometry.thickness - present_thickness) / (1e9) * 0.9167
    % end
    j = 1; % counting to place correct in struct
    mass_balance_curve_struct = struct();
    mass_balance_curve_struct.mass_balance = {};
    mass_balance_curve_struct.time = {};
    figure(111)
    set(gcf,'Position',[100 100 1500 1500])
    for i=1:N
        md = md_list(i);
    
        %% Volume plot 1
        vol1 = cell2mat({md.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
        vol_times1 = cell2mat({md.results.TransientSolution(:).time});

        plot(vol_times1, vol1 - vol1(1), 'color', CM(i,:), 'LineWidth', 3.5);
        hold on;

        mass_balance_curve_struct.mass_balance{j} = vol1 - vol1(1);
        mass_balance_curve_struct.time{j} = vol_times1;
        if length(md_control_list) ~= 0
            j = j + 1;
            % scatter(vol_times_c, vol_c - vol_c(1), 'color', CM(i,:), 'Marker', marker_control{i});
            %% Volume plot CONTROL
            md_control = md_control_list(i);
            vol_c = cell2mat({md_control.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
            vol_times_c = cell2mat({md_control.results.TransientSolution(:).time});
            plot(vol_times_c, vol_c - vol_c(1), 'color', CM(i,:), 'LineWidth', 3.5, 'LineStyle', marker_control{i});

            mass_balance_curve_struct.mass_balance{j} = vol_c - vol_c(1);
            mass_balance_curve_struct.time{j} = vol_times_c;
        end
    end

    % Assumes first model is the reference one
    mb0 = cell2mat({md_list(1).results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
    model_times = cell2mat({md_list(1).results.TransientSolution(:).time});
    model_times_prior_1972_indeces = find(model_times < 1972);
    offset_prior_1972 = mb0(model_times_prior_1972_indeces(end)) - mb0(model_times_prior_1972_indeces(1));

    [cum_mb_1972_2018, cum_mb_errors] = get_mouginot2019_mb('cumulativeMassBalance');
    mouginot_time_span = linspace(1972, 2018, length(cum_mb_1972_2018));
    plot(mouginot_time_span, cum_mb_1972_2018 + offset_prior_1972, '-', 'color', 'red', 'LineWidth', 1.5);
    h = errorbar(mouginot_time_span, cum_mb_1972_2018 + offset_prior_1972, cum_mb_errors, '--', 'color', 'red', 'LineWidth', 1.0);

    % Set transparency level (0:1)
    alpha = 0.65;   
    % Set transparency (undocumented)
    set([h.Bar, h.Line], 'ColorType', 'truecoloralpha', 'ColorData', [h.Line.ColorData(1:3); 255*alpha]);

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
    legend(md_names, 'Mouginot et al. (2019)')
    grid on

    exportgraphics(gcf, fullfile(save_path, 'mass_balance_time_series.png'), 'Resolution', 300)
end