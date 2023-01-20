function [area, index] = get_largest_shape(shape_table)
    areas = zeros(height(shape_table), 1);

    for i=1:height(shape_table)
        x = shape_table.X{i};
        x(isnan(x)) = [];
        y = shape_table.Y{i};
        y(isnan(y)) = [];
        areas(i) = polyarea(x, y);
    end
    [area, index] = max(areas);
end