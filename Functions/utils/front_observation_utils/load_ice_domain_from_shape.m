function ice_domain = load_ice_domain_from_shape(shape_path)
    shape_table = shaperead(shape_path);
    ice_domain = table({shape_table.X}, {shape_table.Y},'VariableNames',["X", "Y"]); % the {} is not necessary, but keeps notation consistent in rest of code

    nan_index = isnan(ice_domain.X{1});
    ice_domain.X{1} = ice_domain.X{1}(~nan_index);
    nan_index = isnan(ice_domain.Y{1});
    ice_domain.Y{1} = ice_domain.Y{1}(~nan_index);

    [v, w] = unique(ice_domain.X{1} + ice_domain.Y{1}, 'stable');
    duplicate_indices = setdiff( 1:numel(ice_domain.X{1}), w );
    ice_domain.X{1}(duplicate_indices) = [];
    ice_domain.X{1} = ice_domain.X{1};
    ice_domain.Y{1}(duplicate_indices) = [];
    ice_domain.Y{1} = ice_domain.Y{1};

    assert(length(ice_domain.X{1}) == length(ice_domain.Y{1}), 'X and Y no longer have the same length')
end