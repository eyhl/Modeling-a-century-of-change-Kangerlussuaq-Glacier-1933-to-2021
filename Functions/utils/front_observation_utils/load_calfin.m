function [shape_data] = load_calfin(file_path)
    %% LOAD_CALFIN() loads calfin termini shapes and converts to table
    % NOTES 
    % NaN codes for end of polygon (at index end), 
    % Closed polygon, i.e. repeated points at index: end-1 = 1
    shape_data = shaperead(file_path);
    shape_data = struct2table(shape_data); % converts to table format like autoterm

    % remove NaN (codes for closed polygon in GIS programs etc)
    for i=1:height(shape_data)
        nan_index = find(isnan(shape_data.X{i}));
        shape_data.X{i}(nan_index) = [];
        shape_data.Y{i}(nan_index) = [];
    end
    
    % fix Date variable type
    shape_data.Date = string(shape_data.Date);
    % unpack some calfin data manually to fit data format of autoterm
    % shape_data.Geometry = vertcat(shape_data.Geometry{:});
    % shape_data.Satellite = vertcat(shape_data.Satellite{:});
    % shape_data.Date = vertcat(shape_data.Date{:});
    % shape_data.OfficialN = vertcat(shape_data.OfficialN{:});
    % shape_data.AltName = vertcat(shape_data.AltName{:});
    % shape_data.RefName = vertcat(shape_data.RefName{:});
    % shape_data.Author = vertcat(shape_data.Author{:});
end