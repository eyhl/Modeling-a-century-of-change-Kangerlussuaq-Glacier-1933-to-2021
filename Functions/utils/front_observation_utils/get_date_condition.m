function condition_array = get_date_condition(shape_table, condition, date_time)
    % condition: string=['<=', '<', '>=', '>']
    % date_time: datetime object, i.e. datetime("01-Jan-1982")
    % if only one input it just returns a condition array with all trues
    condition_array = true(height(shape_table), 1);
    if nargin > 1
        for i=1:height(shape_table)
            if strcmp(condition, '<=')
                condition_array(i, 1) = shape_table.Date{i} <= date_time;

            elseif strcmp(condition, '<')
                condition_array(i, 1) = shape_table.Date{i} < date_time;

            elseif strcmp(condition, '>=')
                condition_array(i, 1) = shape_table.Date{i} >= date_time;

            elseif strcmp(condition, '>')
                condition_array(i, 1) = shape_table.Date{i} <= date_time;
            end
        end
    end
end