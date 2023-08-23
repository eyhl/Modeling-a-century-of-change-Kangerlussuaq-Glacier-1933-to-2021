function plot_bar_differences(md_list, colormaps, legend_names, yaxis_scaling)

    time_ref = floor(cell2mat({md_list(1).results.TransientSolution(:).time}));
    % yr_times = floor(times);
    vol_ref = cell2mat({md_list(1).results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167;
    vol_0 = vol_ref(1);
    vol_ref = vol_ref - vol_0;

    array = zeros(89, length(md_list)-1);
    array_Gt = zeros(89, length(md_list)-1);

    for j=2:length(md_list)
        vol1 = cell2mat({md_list(j).results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167 - vol_0;
        time1 = floor(cell2mat({md_list(j).results.TransientSolution(:).time}));
        for i=1933:2021
            index_ref = find(time_ref == i, 1);
            index1 = find(time1 == i, 1);

            % find average yearly volume for year i
            vol_yr_ref = mean(vol_ref(index_ref), 'omitnan');
            vol_yr1 = mean(vol1(index1), 'omitnan');

            % subtract volumes from reference
            % vol_diff1 = abs(vol_yr1 - vol_yr_ref) / abs(vol_ref(end)) * 100;
            vol_diff_perc = (vol_yr_ref - vol_yr1) / vol_ref(end) * 100;
            vol_diff_Gt = -(vol_yr_ref - vol_yr1);

            % save vol per row and year in columns
            array(i-1932, j-1) = vol_diff_perc;
            array_Gt(i-1932, j-1) = vol_diff_Gt;
        end

    end
    
    yyaxis right
    max_percentage = max(max(abs(round(array./50) * 50)))
    if max_percentage > 50
        max_Gt = 300;
        gt_step = 50;
        percentage_step = 20;
    else
        max_Gt = 150;
        gt_step = 25;
        percentage_step = 10;
    end
    % patch([1930, 1930, 2023, 2023], [0, patch_max, patch_max, 0], [0.7, 0.7, 0.7], 'FaceAlpha', 0.5, 'EdgeColor', 'none')

    yyaxis left
    hB=bar(1933:2021, array_Gt(1:end, :), 'FaceColor','flat','EdgeColor','none');
    % set color and transparency of bars
    for i=1:length(md_list)-1
        hB(i).CData = colormaps(i+1,:);
        hB(i).FaceAlpha = 0.8;
    end
    ax = gca;
    ax.YAxis(1).Limits = [-max_Gt max_Gt];
    ax.YAxis(1).TickValues = [-max_Gt:gt_step:max_Gt];
    ax.YAxis(1).TickLabels = [-max_Gt:gt_step:max_Gt];
    ytl = get(gca, 'YTick');                                    % Get Controlling Left Ticks

    ax.YAxis(1).Color = [0, 0, 0];
    ylabel({'Difference (Gt)'},'FontSize', 12)

    yyaxis right
    hB2=bar(1933:2021, array(1:end, :), 'FaceColor','none','EdgeColor','none');

    ax = gca;
    ax.YAxis(end).Limits = [-max_percentage max_percentage];
    ax.YAxis(end).TickValues = [-max_percentage:percentage_step:max_percentage];
    ax.YAxis(end).TickLabels = [-max_percentage:percentage_step:max_percentage];
    ax.YAxis(end).Color = [0, 0, 0];
    xlabel('Year', 'FontSize', 12')
    ylabel({'Relative';'difference (%)'},'FontSize', 12)
    ytr = get(gca, 'YTick')                                    % Get Right Tick Values
    ytrv = linspace(min(ytr), max(ytr), numel(ytl))            % Create New Right Tick Values Matching Number Of Left Ticks
    ytrc = compose('%.0f',ytrv);                                % Tick Label Cell Array
    set(gca, 'YTick',ytrv, 'YTickLabel',ytrc) 
    grid on

    % legend(legend_names, 'Location', 'northwest', 'FontSize', 12)

    % print median of difference with min and max for each experiment
    for i=1:length(md_list)-1
        disp(['Median difference is ' num2str(median(array_Gt(:,i)), '%.2f') ' Gt, min=' num2str(min(array_Gt(:,i)), '%.2f') ' Gt, max=' num2str(max(array_Gt(:,i)), '%.2f') ' Gt for ' legend_names{i+1} '.'])
    end
    disp(' ')
    for i=1:length(md_list)-1
        disp(['Median difference is ' num2str(median(array(:,i)), '%.2f') ' %, min=' num2str(min(array(:,i)), '%.2f') ' %, max=' num2str(max(array(:,i)), '%.2f') ' % for ' legend_names{i+1} '.'])
    end
    disp(' ')
end