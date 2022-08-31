function [all_months_in_year] = find_year_in_multishp(contour, requested_year)
    %%
    % helper function to extract all fronts in a specific year. 
    % NOTE: It is used in set_ice_levelset_to_front_position(), but that function is not used so in principle this could be deleted. 
    
    multi_shp_size = size(contour, 2);

    % find dates in shape
    year_names = zeros(multi_shp_size);
    for i = 1:multi_shp_size
        year_names(i) = date2decyear(datenum(contour(i).Date));
    end

    pos = find(int32(floor(year_names)) == requested_year);

    all_months_in_year = contour(pos);
end