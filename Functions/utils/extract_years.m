function [year_array, year_indeces] = extract_years(year_struct)
    %% 
    % Helper function to extract years from struct. Hardcoded to work with KQ data (shape files)
    % NOTE: Used in merge_shape_files_script.m and simple_shape_test.m

    year_array = [];
    for i=1:length(year_struct)
        if str2num(year_struct{i}) > 0
            year_array(i) = str2num(year_struct{i});
        elseif strcmp(year_struct{i}, 'LIA')
            year_array(i) = 1900;
        end
    end
    
    year_array(find(year_array == 0)) = [];
    [year_array, year_indeces] = sort(year_array);
end