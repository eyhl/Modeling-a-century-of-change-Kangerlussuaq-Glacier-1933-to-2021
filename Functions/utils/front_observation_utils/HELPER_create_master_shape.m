function stack = connect_stack2master_shape(fjord_shape, ice_levelset_domain)
    % find end points closest to master_shape
    [dist_1, index_1] = find_shortest_distance([fjord_shape.X{i}(1), fjord_shape.Y{i}(1)], ice_levelset_domain);
    [dist_end, index_end] = find_shortest_distance([fjord_shape.X{i}(end), fjord_shape.Y{i}(end)], ice_levelset_domain);

    % find orientation, i.e. is ice_levelset_domain(1) close to fjord_shape.X{i}(1) or not?
    [~, orientation] = min(index_1 - [1, length(fjord_shape.X{i})]);
    
    % reconstruct new shape:
    [first_part_X, last_part_X, first_part_Y, last_part_Y] = get_shape_extremities(ice_levelset_domain, orientation, index_1, index_end);
    stack.X{i} = [first_part_X, stack.X{i}, last_part_X];
    stack.Y{i} = [first_part_Y, stack.Y{i}, last_part_Y];
end