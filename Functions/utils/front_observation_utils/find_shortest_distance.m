function [distance, index] = find_shortest_distance(point, shape)
    %% FIND_SHORTEST_DISTANCE() finds the shortest distance between a point and a shape
    % and returns the distance and the corresponding index.
    % point(1) = X coordinate and point(2) = Y coordinates
    x_diff = point(1) - shape.X{1};
    y_diff = point(2) - shape.Y{1};
    distance = sqrt(x_diff.^2 + y_diff.^2);
    [distance, index] = min(distance);
end