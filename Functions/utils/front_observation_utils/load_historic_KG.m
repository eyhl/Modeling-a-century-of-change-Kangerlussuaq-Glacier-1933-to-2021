function [shape_data] = load_historic_KG(file_path)
    %% LOAD_HISTORIC_KG() loads historical front observations for Kangerlussuaq (KG)
    % glacier. Data format requires some hardcoding.
    shape_data = shaperead(file_path);
    shape_data = struct2table(shape_data); % converts to table format like autoterm
    save_index = zeros(height(shape_data), 1);

    % the 1900 date has to be handled seperately
    shape_data.date{21} = datetime('31-07-1900', 'InputFormat', 'dd-MM-yyyy');
    j = 0;
    for i = 1:height(shape_data)
        j = j + 1;
        try
            if isempty(shape_data.date{i})
                date = datetime(append('31-07-', shape_data.NAME{i}), 'InputFormat', 'dd-MM-yyyy');
                date.Format = 'yyyy-MM-dd';
                shape_data.date{i} = date;
            else
                date = datetime(shape_data.date{i}, 'InputFormat', 'yyyyMMdd');
                date.Format = 'yyyy-MM-dd';
                shape_data.date{i} = date;
            end

        catch
            save_index(j) = i;
            continue
        end
    end
    fprintf('Removing data row %s (no date info)\n', num2str(save_index(save_index~=0)))
    shape_data(save_index(save_index~=0), :) = [];

    % rename date column to Date for consistency
    shape_data = renamevars(shape_data,["date"],["Date"]);

    % fix Date variable type
    shape_data.Date = string(shape_data.Date);

    % sort by date
    [~, ind] = sort(datetime(shape_data.Date(:)));
    shape_data = shape_data(ind, :);
    % remove nan
    for i=1:height(shape_data)
        nan_index = find(isnan(shape_data.X{i}));
        shape_data.X{i}(nan_index) = [];
        shape_data.Y{i}(nan_index) = [];
    end
end