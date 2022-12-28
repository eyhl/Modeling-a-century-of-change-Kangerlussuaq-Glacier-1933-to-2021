function [x_inner, y_inner] = merge_shape_files(x_inner, y_inner, x_outer, y_outer)

    % if y_inner(1) > nanmean(y_inner)
    %     x_inner = fliplr(x_inner);
    %     y_inner = fliplr(y_inner);
    % elseif y_outer(1) > nanmean(y_outer)
    %     x_outer = fliplr(x_outer);
    %     y_outer = fliplr(y_outer);
    % end
    %% remove nans from inner polygon
    x_inner(isnan(x_inner)) = [];
    y_inner(isnan(y_inner)) = [];
    x_outer(isnan(x_outer)) = [];
    y_outer(isnan(y_outer)) = [];

    %% remove duplicates
    inner_coords = [x_inner', y_inner'];
    [unqA, ia, ic] = unique(inner_coords, 'rows', 'stable'); % to respect orignal order in unqA
    inner_coords = reshape(unqA, [], 2);
    x_inner = inner_coords(:, 1)';
    y_inner = inner_coords(:, 2)';

    outer_coords = [x_outer', y_outer'];
    [unqA, ia, ic] = unique(outer_coords, 'rows', 'stable'); % to respect orignal order in unqA
    outer_coords = reshape(unqA, [], 2);
    x_outer = outer_coords(:, 1)';
    y_outer = outer_coords(:, 2)';

    % find the point where there is a large jump in y-coordinate (only works for east-west'ish glaciers) 
    [~, final_index] = max(abs(diff([y_inner, y_inner(1)]))); % y_inner(1) for making sure that final index = end if this is the case
    x_inner = x_inner(1:final_index);
    y_inner = y_inner(1:final_index);
    
    % disp(sprintf('%.2f', x_inner(1)))
    % disp(sprintf('%.2f', y_inner(1)))
    % disp(sprintf('%.2f', x_inner(final_index)))
    % disp(sprintf('%.2f', y_inner(final_index)))

    %%  fix first end point (1)
    % find min distance between inner shp end points and outer shape
    dist_x = x_inner(1) - x_outer;
    dist_y = y_inner(1) - y_outer;
    distances = sqrt(dist_x.^2 + dist_y.^2);
    [bottom_nearest_point, bottom_index] = min(distances);

    %%  fix second end point (end)
    dist_x = x_inner(end) - x_outer;
    dist_y = y_inner(end) - y_outer;
    distances = sqrt(dist_x.^2 + dist_y.^2);
    [top_nearest_point, top_index] = min(distances);

    % figure();
    % scatter(x_outer, y_outer, 'b');
    % hold on 
    % scatter(x_outer(1), y_outer(1), 'r'); 
    % scatter(x_outer(end), y_outer(end), 'g'); 
    % exportgraphics(gcf, 'master_shape.png') 
    % hold off

    [val, ind] = min(([y_outer(bottom_index) - y_inner(1), y_outer(bottom_index) - y_inner(end)]));
    if ind == 1
        index_1 = bottom_index;
        index_2 = top_index;
    elseif ind == 2
        index_1 = top_index;
        index_2 = bottom_index;
    end

    x_range_1 = x_outer(1:index_1);
    x_range_2 = x_outer(index_2:end);
    
    y_range_1 = y_outer(1:index_1);
    y_range_2 = y_outer(index_2:end);

    % make sure that arrays are flipped the right way, if index 2 is closest to 1 -> flip
    [~, ind] = min(abs([y_inner(1) - y_outer(index_1), y_inner(1) - y_outer(index_2)]));
    if ind == 2
        x_inner = fliplr(x_inner);
        y_inner = fliplr(y_inner);
    end


    % connect shapes, sandwich method        
    x_inner = [x_range_1, x_inner, x_range_2];
    y_inner = [y_range_1, y_inner, y_range_2];  


    % select the appropriate index for outer shape
    % index_1 = min([bottom_index, top_index]);
    % index_2 = max([bottom_index, top_index]);

    % x_range_1 = x_outer(1:index_1);
    % x_range_2 = x_outer(index_2:end);
    
    % y_range_1 = y_outer(1:index_1);
    % y_range_2 = y_outer(index_2:end);

    % % connect shapes, sandwich method        
    % x_inner = [x_range_1, x_inner, x_range_2];
    % y_inner = [y_range_1, y_inner, y_range_2];

    % set last value to be NaN and check for too many nans
    if sum(isnan(x_inner)) == 0 || sum(isnan(y_inner)) == 0
        x_inner(end+1) = NaN;
        y_inner(end+1) = NaN;
    elseif sum(isnan(x_inner)) > 1 || sum(isnan(y_inner)) > 1
        disp('Warning, more than one NaN value')
    end

    % check for duplicates
    [unqA,~,id] = unique(y_inner);
    length(id)
    out = unqA(histc(id,1:max(id))>1);
    length(y_inner)
    if abs(length(id) - length(y_inner)) > 2
        disp('Warning, more than one pair of duplicate coordinates')
    end
end
