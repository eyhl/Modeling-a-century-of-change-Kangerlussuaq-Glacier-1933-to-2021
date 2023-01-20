function stack = connect_stack2master_shape(stack, master_shape)
    for i=1:height(stack)
        % find end points closest to master_shape
        [dist_1, index_1] = find_shortest_distance([stack.X{i}(1), stack.Y{i}(1)], master_shape);
        [dist_end, index_end] = find_shortest_distance([stack.X{i}(end), stack.Y{i}(end)], master_shape);

        % find orientation, i.e. is master(1) close to stack.X{i}(1) or not?
        [~, orientation] = min(index_1 - [1, length(stack.X{i})]);
        % fprintf("%d, %d, %d\n", index_1, index_end, orientation)
        [first_part_X, last_part_X, first_part_Y, last_part_Y] = get_shape_extremities(master_shape, orientation, index_1, index_end);
        
        % reconstruct new shape:
        stack.X{i} = [first_part_X, stack.X{i}, last_part_X];
        stack.Y{i} = [first_part_Y, stack.Y{i}, last_part_Y];
    end
end