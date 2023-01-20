function [stack] = combine_stacks(stacks, conditions)
    % stacks: cell array with a table in each cell array element
    % conditions: cell array with filtering conditions for each stack
    % Will only return X, Y and Date as this is the only info needed for ISSM
    % if you want to have more, for now you have to refer back to original data
    
    % create empty table
    stack  = cell2table(cell(0,3), 'VariableNames', {'X', 'Y', 'Date'});
    for i=1:length(stacks)
        if nargin < 2
            current_stack = stacks{i};
            stack = [stack; current_stack];
        else
            % filter table at position i
            current_stack = stacks{i};
            current_stack = current_stack(conditions{i}, :);
            current_stack = current_stack(:, {'X', 'Y', 'Date'});
            stack = [stack; current_stack];
        end
    end
    % sort by date
    [~, ind] = sort(datetime(stack.Date(:)));
    stack = stack(ind, :);

    % stack = stack(2:end, :);
end