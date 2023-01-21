function [orientation] = compare_orientation(shapeA, shapeB, index_1, index_2);
    %% COMPARE_ORIENTATION() compares the orientation of the two input shapes
    % returns false if they are the different and true if they are the same.
    % it checks if shape1(1) is closer to shape2(index_1) or shape2(index_end)
    pointA_1 = [shapeA.X{1}(1), shapeA.Y{1}(1)];
    pointA_end = [shapeA.X{1}(end), shapeA.Y{1}(end)];
    pointB_1 = [shapeB.X{1}(index_1), shapeB.Y{1}(index_1)];
    pointB_2 = [shapeB.X{1}(index_2), shapeB.Y{1}(index_2)];

    if norm(pointA_1, pointB_1) < norm(pointA_1, pointB_2)
        disp("shapeA(1) is closer to shape2(index_1)");
        orientation = "same";

    elseif norm(pointA_1, pointB_1) > norm(pointA_1, pointB_2)
        disp("shapeA(1) is closer to shape2(index_2)");
        orientation = "reverse";

    elseif norm(pointA_end, pointB_1) > norm(pointA_end, pointB_2)
        disp("shapeA(end) is closer to shape2(index_2)");
        orientation = "same";

    elseif norm(pointA_end, pointB_1) < norm(pointA_end, pointB_2)
        disp("shapeA(end) is closer to shape2(index_1)");
        orientation = "reverse";

    elseif norm(pointA_end, pointB_1) == norm(pointA_end, pointB_2)
        disp("Points are equidistant: shapeA(end) == shapeB(index_1) == shapeB(index_2)")
        orientation = NaN;

    elseif norm(pointA_1, pointB_1) == norm(pointA_1, pointB_2)
        disp("Points are equidistant: shapeA(1) == shapeB(index_1) == shapeB(index_2)")
        orientation = NaN;
    else 
        fprintf("No condition met for points: (%.6g, %.6g) and (%.6g, %.6g)\n", pointA_1, pointA_end. pointB_1, pointB_2)
    end
end