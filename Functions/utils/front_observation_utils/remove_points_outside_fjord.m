function [shape_table] = remove_points_outside_fjord(shape_table, fjord_shape)
    % CONFINE_SHAPE_EXTEND_TO_FJORD takes in a multipolygon type shape (several shapes) in the format of a table
    % and removes excess coordinates, outside the fjord walls. 
    % NOTE: the function assumes that the table has a field called X and Y
    % TODO: add additional optional preprocessing like snapping loops and smoothening
    try
        [~] = shape_table.X(1);
    catch me
        warning("shape_table should have a field called X and a field called Y")
    end
    N = max(size(shape_table));
    if iscell(shape_table.X(1))
        for i=1:N
            points = [shape_table.X{i}; shape_table.Y{i}];
            points = inside_fjord(points, fjord_shape);
            shape_table.X{i} = points(1, :);
            shape_table.Y{i} = points(2, :);

            if rem(i, 100) == 0
                fprintf("Removing excess points at shape no. %d/%d\n", i, N)
            end
        end
    else
        for i=1:N
            points = [shape_table.X(i); shape_table.Y(i)];
            points = inside_fjord(points, fjord_shape);
            shape_table.X(i) = points(1, :);
            shape_table.Y(i) = points(2, :);
            if rem(i, 100) == 0
                fprintf("Removing excess points at shape no. %d/%d\n", i, N)
            end
        end    
    end
    fprintf("Removing excess points at shape no. %d/%d\n", N, N)
end
