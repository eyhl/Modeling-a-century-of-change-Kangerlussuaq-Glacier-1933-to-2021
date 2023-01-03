function [I] = integrate_field_spatially(md, field)
    % Integrates field in space per time step, by computing the area-weighted average
    % assumes a time step per column.
    
    % get areas of all elements
    mesh_areas = GetAreas(md.mesh.elements, md.mesh.x, md.mesh.y);

    % integrated smb
    I = zeros(1, size(field, 2));
    for i=1:size(field, 2)
        % current time step
        smb_tmp = field(:, i);

        % pick smb values per element, and average vertices to one value per element
        delta_smb_elements = smb_tmp(md.mesh.elements) * [1; 1; 1] / 3;

        I(i) = sum(delta_smb_elements .* mesh_areas);
    end
end