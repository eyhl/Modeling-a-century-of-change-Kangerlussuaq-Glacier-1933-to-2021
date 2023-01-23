function stack = connect_stack2master_shape(stack, master_shape, master_shape_type)
    %% CONNECT_STACK2ICE_LEVELSET_DOMAIN() connects each shape in stack to 
    % a master shape. master_shape can be either master_shape sides or embayment sides or the full
    % ice levelset domain. 
    % NOTE: the ice levelset set domain shape should be an open shape which starts and stops 
    % at the embayement or fjord entrance (approx).

    % TODO: MOVE A LOT OF THIS INTO PREPROCESSING OR A GENERAL SHAPE LOADER TO "STACK" format!!
    % TODO: NOT SURE THE ICE LEVELSET LOGIC HOLDS IN GENERAL

    master_points = [master_shape.X{1}; master_shape.Y{1}];

    for i=1:height(stack)
        fprintf("Shape no. %d\n", i)
        
        % temporary for readability
        shapeA = stack(i, :);

        % extract end-points
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
                stack.X{i} = [master_shape.X{1}(1:ind2), fliplr(shapeA.X{1}), master_shape.X{1}(ind1:end)];
                stack.Y{i} = [master_shape.Y{1}(1:ind2), fliplr(shapeA.Y{1}), master_shape.Y{1}(ind1:end)];
            else
                disp("Something is wrong index1 = index2")
            end
            % if i == 100
            %     clf;
            %     figure(1);
            %     plot(vecnorm(point_1 - master_points)); hold on
            %     plot(vecnorm(point_end - master_points));
            %     figure(2)
            %     plot(stack.X{i}, stack.Y{i}, '-X'); hold on
            %     plot(master_shape.X{1}, master_shape.Y{1}, '-o');
            %     % scatter(point_1(1), point_1(2), 'ro');
            %     point_end(1), point_end(2)
            %     pause
            % end
        elseif strcmp(master_shape_type, 'ice_levelset')
            % assumes a shape that starts and ends approximately where fjord/embayment starts and ends
            if ind1 < ind2  % master shape starts closer to shapeA(1)
                stack.X{i} = [fliplr(master_shape.X{1}), stack.X{i}];
                stack.Y{i} = [fliplr(master_shape.Y{1}), stack.Y{i}];
            elseif ind1 > ind2 % master shape starts closer to shapeA(end)
                stack.X{i} = [stack.X{i}, master_shape.X{1}];
                stack.Y{i} = [stack.Y{i}, master_shape.Y{1}];
            else
                disp("Something is wrong index1 = index2 :)")

            end
        else
            warning("master_shape_type not known. Select 'fjord', 'embayment' or 'ice_levelset'")
        end
    end
end