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
end