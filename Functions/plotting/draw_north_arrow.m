function draw_north_arrow(x, y, arrowSize, arrowLineWidth, arrowHeadSize)
    % Draw a north arrow on top of a plot

    % Default values for arrow properties
    if nargin < 5
        arrowHeadSize = 0.2;
    end
    if nargin < 4
        arrowLineWidth = 1.5;
    end
    if nargin < 3
        arrowSize = 0.2;
    end

    % Get the current axis limits
    ax = gca;
    xlim = get(ax, 'XLim');
    ylim = get(ax, 'YLim');

    % Calculate the coordinates for the north arrow
    arrowLength = arrowSize * (ylim(2) - ylim(1));

    % Draw the stem of the arrow
    line([x x], [y y+arrowLength], 'Color', 'w', 'LineWidth', arrowLineWidth);

    % Draw the arrowhead
    arrowHeadX = [x-arrowHeadSize/2 x x+arrowHeadSize/2];
    arrowHeadY = [y+arrowLength-arrowHeadSize y+arrowLength y+arrowLength-arrowHeadSize];
    patch(arrowHeadX, arrowHeadY, 'w', 'EdgeColor', 'w', 'LineWidth', arrowLineWidth);
end
    