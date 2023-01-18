function [shape_data] = load_calfin(file_path)
    %% LOAD_CALFIN() loads calfin termini shapes and converts to table
    % NOTES 
    % NaN codes for end of polygon (at index end), 
    % Closed polygon, i.e. repeated points at index: end-1 = 1
    shape_data = shaperead(file_path);
    shape_data = struct2table(shape_data); % converts to table format like autoterm
end