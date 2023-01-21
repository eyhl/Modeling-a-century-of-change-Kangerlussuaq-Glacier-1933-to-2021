function stack = connect_stack2master_shape(stack, master_shape, master_shape_type)
    %% CONNECT_STACK2ICE_LEVELSET_DOMAIN() connects each shape in stack to 
    % a master shape. master_shape can be either master_shape sides or embayment sides or the full
    % ice levelset domain. 
    % NOTE: the ice levelset set domain shape should be an open shape which starts and stops 
    % at the embayement or fjord entrance (approx).
    master_points = [master_shape.X{1}; master_shape.Y{1}];
    for i=1:height(stack)
        % find end points closest to master_shape
        % [dist_1, index_1] = find_shortest_distance([stack.X{i}(1), stack.Y{i}(1)] + 1, master_shape);
        % [dist_end, index_end] = find_shortest_distance([stack.X{i}(end), stack.Y{i}(end)] + 1, master_shape);
        
        % temporary for readability
        shapeA = stack(i, :);
        point_1 = [shapeA.X{1}(1); shapeA.Y{1}(1)];
        point_end = [shapeA.X{1}(end); shapeA.Y{1}(end)];

        % find the index of shortest distance between end points and the master shape
        [~, ind1] = min(vecnorm(point_1 - master_points));
        [~, ind2] = min(vecnorm(point_end - master_points));

        % find orientation and create new shape
        if strcmp(master_shape_type, 'fjord') || strcmp(master_shape_type, 'embayment')
            % assumes that the biggest gap btw. points are the fjord gap
            if ind1 < ind2 % master shape starts closer to shapeA(1)
                stack.X{i} = [master_shape.X{1}(1:ind1), shapeA.X{1}, master_shape.X{1}(ind2:end)];
                stack.Y{i} = [master_shape.Y{1}(1:ind1), shapeA.Y{1}, master_shape.Y{1}(ind2:end)];

            elseif ind1 > ind2 % master shape starts closer to shapeA(end)
                stack.X{i} = [master_shape.X{1}(1:ind2), shapeA.X{1}, master_shape.X{1}(ind1:end)];
                stack.Y{i} = [master_shape.Y{1}(1:ind2), shapeA.Y{1}, master_shape.Y{1}(ind1:end)];
            else
                disp("Something is wrong index1 = index2")
            end
        elseif strcmp(master_shape_type, 'ice_levelset')
            % assumes a shape that starts and ends approximately where fjord/embayment starts and ends
            if ind1 < ind2  % master shape starts closer to shapeA(1)
                stack.X{i} = [master_shape.X{1}, stack.X{i}];
                stack.Y{i} = [master_shape.Y{1}, stack.Y{i}];
            elseif ind1 > ind2 % master shape starts closer to shapeA(end)
                stack.X{i} = [stack.X{i}, master_shape.X{1}];
                stack.Y{i} = [stack.Y{i}, master_shape.Y{1}];
            else
                disp("Something is wrong index1 = index2")

            end
        else
            warning("master_shape_type not known. Select 'fjord', 'embayment' or 'ice_levelset'")
        end
    end
end