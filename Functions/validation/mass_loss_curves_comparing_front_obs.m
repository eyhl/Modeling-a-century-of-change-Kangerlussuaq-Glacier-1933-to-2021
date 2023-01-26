function [mass_balance_curve_struct] = mass_loss_curves_comparing_front_obs(md_list, md_control_list, md_names, folder, validate, retreat_advance) %md1, md2, md3, md_control, folder)
    if nargin < 5
        validate = true;
    end
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
    mass_balance_curve_struct.mouginot_t = {};
    mass_balance_curve_struct.mouginot_mb = {};
    mass_balance_curve_struct.mouginot_eps = {};
    mass_balance_curve_struct.mouginot_offset = {};
    figure(111)
    set(gcf,'Position',[100 100 1500 1500])
    for i=1:N
        md = md_list(i);
    
        %% Volume plot 1
        vol1 = cell2mat({md.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
        vol_times1 = cell2mat({md.results.TransientSolution(:).time});

        p = plot(vol_times1, vol1 - vol1(1), 'color', CM(i,:), 'LineWidth', 2.0);
        hold on;
        % p.Color(4) = 0.70 - (i-1)*0.40;
        mass_balance_curve_struct.mass_balance{j} = vol1 - vol1(1);
        mass_balance_curve_struct.time{j} = vol_times1;
        if length(md_control_list) ~= 0
            j = j + 1;
            % scatter(vol_times_c, vol_c - vol_c(1), 'color', CM(i,:), 'Marker', marker_control{i});
            %% Volume plot CONTROL
            md_control = md_control_list(i);
            vol_c = cell2mat({md_control.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
            vol_times_c = cell2mat({md_control.results.TransientSolution(:).time});
            % plot(vol_times_c, vol_c - vol_c(1), 'color', CM(i,:), 'LineWidth', 3.5, 'LineStyle', marker_control{i});

            q_times = md_control.levelset.spclevelset(end, :);

            if i == 1
                q_times_historic = q_times(1:5);
            else
                q_times_historic = [q_times(1:4), q_times(6)];
            end

            vol_tmp = interp1(vol_times_c, vol_c - vol_c(1), q_times);
            vol_tmp_historic = interp1(vol_times_c, vol_c - vol_c(1), q_times_historic);
            % CM(i,:)
            plot(q_times, vol_tmp, 'color', CM(i,:) .* 0.7, 'marker', '+', 'LineStyle', 'none', 'MarkerSize', 7, 'LineWidth', 2);
            plot(q_times_historic, vol_tmp_historic, 'color', 'magenta', 'marker', 'o', 'LineStyle', 'none', 'MarkerSize', 7, 'LineWidth', 1);
            mass_balance_curve_struct.mass_balance{j} = vol_c - vol_c(1);
            mass_balance_curve_struct.time{j} = vol_times_c;
        end
    end

    if retreat_advance
        % plot a retreat advance background
        flowline = load("/data/eigil/work/lia_kq/Data/validation/flowline_positions/central_flowline.mat");
        flowline = flowline.flowlineList{:};
        [distance, ~, ~] = get_central_front_position(md_list(1), flowline); % distance is measured from most extended front
        t_front_obs = md_list(1).levelset.spclevelset(end, :);
        t_query = md_list(1).results.TransientSolution(:).time;
        distance_q = interp1(t_front_obs, -distance, t_query); % distance linear interpolated for all available times
        gradient_q = gradient(distance_q);

        % reduce gradient to a sign function for positive and negative gradient
        gradient_q(gradient_q<0) = max([-1, gradient_q(gradient_q<0)]);
        gradient_q(gradient_q>0) = min([1, gradient_q(gradient_q>0)]);     

        [xx1, yy1, xx2, yy2] = plot_background(t_query, gradient_q, [-400, 50]);
    end

    if validate
        % Assumes first model is the reference one
        mb0 = cell2mat({md_list(1).results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
        model_times = cell2mat({md_list(1).results.TransientSolution(:).time});
        model_times_prior_1972_indeces = find(model_times < 1972);
        offset_prior_1972 = mb0(model_times_prior_1972_indeces(end)) - mb0(model_times_prior_1972_indeces(1));

        [cum_mb_1972_2018, cum_mb_errors] = get_mouginot2019_mb('cumulativeMassBalance');
        mouginot_time_span = linspace(1972, 2018, length(cum_mb_1972_2018));
        plot(mouginot_time_span, cum_mb_1972_2018 + offset_prior_1972, '-', 'color', 'red', 'LineWidth', 1.5);
        h = errorbar(mouginot_time_span, cum_mb_1972_2018 + offset_prior_1972, cum_mb_errors, '--', 'color', 'red', 'LineWidth', 1.0);
        mass_balance_curve_struct.mouginot_t{1} = mouginot_time_span;
        mass_balance_curve_struct.mouginot_mb{1} = cum_mb_1972_2018;
        mass_balance_curve_struct.mouginot_eps{1} = cum_mb_errors;
        mass_balance_curve_struct.mouginot_offset{1} = offset_prior_1972;
        % Set transparency level (0:1)
        alpha = 0.65;   
        % Set transparency (undocumented)
        set([h.Bar, h.Line], 'ColorType', 'truecoloralpha', 'ColorData', [h.Line.ColorData(1:3); 255*alpha]);
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
    xlim([1971, 2023])
    set(gca,'fontsize', 18)
    % grid;
    % ylim([-400, 1000])
    % if validate
    %     legend([md_names, "Mouginot et al. (2019)"])
    % else
    %     legend(md_names)
    % end

    patch(xx1, yy1, 'g', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    patch(xx2, yy2, 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'none');

    if folder
    exportgraphics(gcf, fullfile(save_path, 'mass_balance_time_series.png'), 'Resolution', 300)
    end
end