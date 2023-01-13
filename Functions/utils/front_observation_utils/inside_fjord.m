function condition = inside_fjord(point, fjord_shape)
    n_intersections = count_intersections(point, fjord_shape);
    if iseven(n_intersections)
        condition = false;
    elseif n_intersections == 0
        condition = false;
    else
        condition = true;
    end
end