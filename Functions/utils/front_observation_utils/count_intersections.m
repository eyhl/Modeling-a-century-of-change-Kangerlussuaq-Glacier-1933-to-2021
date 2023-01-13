function sum_intersections = count_intersections(point, fjord_shape)
    disp(point(1))
    line_east_west_x = [point(1) - 1e4, point(1) + 1e4];
    line_east_west_y = [point(2), point(2)];
    line_north_south_x = [point(1), point(1)];
    line_north_south_y = [point(2) - 1e4, point(2) + 1e4];
    [xi, yi] = polyxpoly(line_east_west_x, line_east_west_y, fjord_shape(1, :), fjord_shape(2, :), 'unique');
    sum_intersections = length(xi) + length(yi);
end