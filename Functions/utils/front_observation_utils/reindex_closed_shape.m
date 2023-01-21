function [shape_table] = reindex_closed_shape(shape_table)
    %% REINDEX_CLOSED_SHAPE() checks for NaNs and duplicates, removes them and then
    % goes on to reindex shapes such that 1 and end have the largest possible gap between
    % them. This relies on assuming that the largest gap is from fjord wall to fjord wall,
    % (or embayment side to embayment side) but in some cases it might fail.
    disp('Reindexing shape stack...')
    for i=1:height(shape_table)
        % find duplicates
        [v, w] = unique(shape_table.X{i}, 'stable');
        duplicate_indices = setdiff( 1:numel(shape_table.X{i}), w );
        shape_table.X{i}(duplicate_indices) = [];

        [v, w] = unique(shape_table.Y{i}, 'stable');
        duplicate_indices = setdiff( 1:numel(shape_table.Y{i}), w );
        shape_table.Y{i}(duplicate_indices) = [];
        assert(length(shape_table.X{i}) == length(shape_table.Y{i}), 'X and Y no longer have the same length')

        % find largest coordinate gap in shape, i.e. jumps across fjord
        diff_x = diff(shape_table.X{i});
        diff_y = diff(shape_table.Y{i});
        gaps = sqrt(diff_x.^2 + diff_y.^2);
        [~, index] = max(gaps);
        index_offset = length(shape_table.X{i}) - index;
        assert(index_offset >= 0, 'Largest gap is at index >= end, something is wrong')

        % shift coordinates to have index 1 and end just before fjord gap
        shape_table.X{i} = circshift(shape_table.X{i}, index_offset);
        shape_table.Y{i} = circshift(shape_table.Y{i}, index_offset);

        % clf;
        % scatter(shape_table.X{i}(1:5), shape_table.Y{i}(1:5), 10, 'b'); hold on;
        % scatter(shape_table.X{i}(end-5:end), shape_table.Y{i}(end-5:end), 10, 'r');
        % scatter(shape_table.X{i}, shape_table.Y{i}, 1, 'k', 'filled');
        % pause;
    end
end