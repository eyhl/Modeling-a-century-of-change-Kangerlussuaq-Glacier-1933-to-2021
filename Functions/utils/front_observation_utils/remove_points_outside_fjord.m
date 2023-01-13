function [shape_data_x, shape_data_y, indices] = remove_points_outside_fjord(shape_data_x, shape_data_y, fjord_shape)
    indices = 0;
    if inside_fjord([shape_data_x; shape_data_y], fjord_shape)
        remove_points_outside_fjord(shape_data_x(2:end), shape_data_y(2:end), fjord_shape)
        indices = indices + 1;
    end
%     while inside_fjord(shape_data_x(1), fjord_shape)
%         shape_data_x(1) = [];
%     while 
end