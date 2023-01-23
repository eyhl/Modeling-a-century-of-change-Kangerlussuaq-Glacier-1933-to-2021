function ice_domain = load_ice_domain_from_shape(shape_path)
    shape_table = shaperead(shape_path);
    ice_domain = table({shape_table.X}, {shape_table.Y},'VariableNames',["X", "Y"]); % the {} is not necessary, but keeps notation consistent in rest of code
    for i=1:height(ice_domain)
        nan_index = find(isnan(ice_domain.X{i}));
        ice_domain.X{i}(nan_index) = [];
        ice_domain.Y{i}(nan_index) = [];
    end
end