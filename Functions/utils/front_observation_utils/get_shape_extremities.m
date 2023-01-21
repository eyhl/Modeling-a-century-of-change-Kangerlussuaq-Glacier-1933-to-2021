function [first_part_X, last_part_X, first_part_Y, last_part_Y] = get_shape_extremities(master_shape, orientation, index_1, index_end)
    if orientation == 2
        % master and current shape has same orientation
        first_part_X = master_shape.X{1}(1:index_1);
        last_part_X = master_shape.X{1}(index_end:end);
        first_part_Y = master_shape.Y{1}(1:index_1);
        last_part_Y = master_shape.Y{1}(index_end:end);

    elseif orientation == 1
        % master and current shape has same orientation
        first_part_X = master_shape.X{1}(index_1:end);
        last_part_X = master_shape.X{1}(1:index_end);
        first_part_Y = master_shape.Y{1}(index_1:end);
        last_part_Y = master_shape.Y{1}(1:index_end);
    else
        warning('Someting is wrong in orientation logic')
    end

end