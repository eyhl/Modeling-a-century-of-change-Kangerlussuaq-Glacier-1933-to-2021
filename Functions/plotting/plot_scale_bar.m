function plot_scale_bar(imageSize, physicalSize, scaleLength, scaleUnit, position, barHeight, barWidth, barColor, textColor, padding)
    % Plot a scale bar on an image plot

    % Default values for scale bar properties
    if nargin < 10
        padding = 0.1;
    end
    if nargin < 9
        textColor = 'w';
    end
    if nargin < 8
        barColor = 'w';
    end
    if nargin < 7
        barWidth = 5;
    end
    if nargin < 6
        barHeight = 0.05;
    end
    if nargin < 5
        position = 'bottomright';
    end

    % Get the current axis limits
    ax = gca;
    xlim = get(ax, 'XLim');
    ylim = get(ax, 'YLim');

    % Calculate the size of one pixel in the x and y directions
    dx = imageSize(1) / (physicalSize(1) / 1000)
    dy = physicalSize(2) / imageSize(2);

    % Convert the scale length to meters
    scaleLengthMeters = scaleLength; % Convert kilometers to meters

    % Convert the scale length to the number of pixels
    scaleLengthPixels = scaleLength * dx

    % Calculate the coordinates for the scale bar
    switch lower(position)
        case 'bottomright'
            barX = xlim(2) - scaleLengthPixels - padding * (xlim(2) - xlim(1));
            barY = ylim(1) + (ylim(2) - ylim(1)) * barHeight;
            textX = xlim(2) - scaleLengthPixels / 2 - padding * (xlim(2) - xlim(1));
            textY = ylim(1) + (ylim(2) - ylim(1)) * (barHeight + 0.05);
        case 'bottomleft'
            barX = xlim(1) + padding * (xlim(2) - xlim(1));
            barY = ylim(1) + (ylim(2) - ylim(1)) * barHeight;
            textX = xlim(1) + scaleLengthPixels / 2 + padding * (xlim(2) - xlim(1));
            textY = ylim(1) + (ylim(2) - ylim(1)) * (barHeight + 0.05);
        case 'topright'
            barX = xlim(2) - scaleLengthPixels - padding * (xlim(2) - xlim(1));
            barY = ylim(2) - (ylim(2) - ylim(1)) * barHeight;
            textX = xlim(2) - scaleLengthPixels / 2 - padding * (xlim(2) - xlim(1));
            textY = ylim(2) - (ylim(2) - ylim(1)) * (barHeight + 0.05);
        case 'topleft'
            barX = xlim(1) + padding * (xlim(2) - xlim(1));
            barY = ylim(2) - (ylim(2) - ylim(1)) * barHeight;
            textX = xlim(1) + scaleLengthPixels / 2 + padding * (xlim(2) - xlim(1));
            textY = ylim(2) - (ylim(2) - ylim(1)) * (barHeight + 0.05);
        otherwise
            error('Invalid position specified. Use ''bottomright'', ''bottomleft'', ''topright'', or ''topleft''.');
    end

    % Plot the scale bar
    hold on;
    line([barX, barX+scaleLengthPixels], [barY, barY], 'Color', barColor, 'LineWidth', barWidth);

    % Add text label to the scale bar
    text(textX, textY, [num2str(scaleLength), ' ', scaleUnit], 'Color', textColor, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12);

    % Reset the axes limits
    set(ax, 'XLim', xlim);
    set(ax, 'YLim', ylim);

    hold off;
end
