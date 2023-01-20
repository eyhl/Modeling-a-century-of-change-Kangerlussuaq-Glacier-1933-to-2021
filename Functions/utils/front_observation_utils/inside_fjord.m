function points = inside_fjord(points, fjord_shape)
    %% INSIDE_FJORD() returns the points which are found inside the fjord_shape
    % points = [x; y]
    % fjord_shape = [x_f; y_f], should be a closed shape

    % finds points inside polygon
    [in, on] = inpolygon(points(1, :), points(2, :), fjord_shape.X{1}, fjord_shape.Y{1});

    % only points in beginning and end of polygon are expected to be noise, so keep the rest.
    first_ind = find(in, 1, 'first');
    last_ind = find(in, 1, 'last');
    in(first_ind:last_ind) = 1;
    points = points(:, in);
end