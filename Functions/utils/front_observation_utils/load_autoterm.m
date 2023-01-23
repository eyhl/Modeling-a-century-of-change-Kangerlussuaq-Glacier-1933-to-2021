function [T] = load_autoterm(file_path)
    % LOAD_AUTOTERM loads autoterm shape data and Tprojects to coordinate system epsg:3413.
    % sorts shape files in time
    %   T = load_autoterm(file_path) returns table with autoterm data with original projection and new
    autoterm_shp = readgeotable(file_path);
    T = geotable2table(autoterm_shp,["Lat","Lon"]);

    % sort by date
    [~, ind] = sort(datetime(T.Date(:)));
    T = T(ind, :);

    for i = 1:max(size(T))
        lon = T.Lon(i);
        lat = T.Lat(i);

        % project lat lon data to epsg:3413 x, y
        [x, y] = projfwd(projcrs(3413), cell2mat(lat), cell2mat(lon)); 

        % save in new columns
        T.X(i) = {x};
        T.Y(i) = {y};
    end

    % remove duplicate dates
    [~, w] = unique(T.Date, 'stable');
    duplicate_indices = setdiff( 1:numel(T.Date), w );
    T(duplicate_indices, :) = [];

    % remove NaN in data
    for i=1:height(T)
        nan_index = find(isnan(T.X{i}));
        T.X{i}(nan_index) = [];
        T.Y{i}(nan_index) = [];

        [v, w] = unique(T.X{i} + T.Y{i}, 'stable');
        duplicate_indices = setdiff( 1:numel(T.X{i}), w );
        T.X{i}(duplicate_indices) = [];
        T.Y{i}(duplicate_indices) = [];
    end

        % remove self-intersections Maybe move to PREPROCESSING
    % reshape to (N, 2)
    % for i=1:height(T)
    %     fprintf("Removing intersections from shape %d/%d\n", i, height(T))
    %     S = reshape(vertcat(T.X{i}, T.Y{i}), [], 2);
    %     S = remove_intersections(S);
    %     T.X{1} = reshape(S(:, 1), 1, []); % not super general, but with proper loading maybe I can ensure wheter shapes are row or column vectors
    %     T.Y{1} = reshape(S(:, 2), 1, []);
    % end
end