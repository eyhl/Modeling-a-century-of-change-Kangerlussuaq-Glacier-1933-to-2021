function ice_domain = load_ice_domain_from_shape(shape_path)
    shape_table = shaperead(shape_path);
    ice_domain = table({shape_table.X}, {shape_table.Y},'VariableNames',["X", "Y"]); % the {} is not necessary, but keeps notation consistent in rest of code
end