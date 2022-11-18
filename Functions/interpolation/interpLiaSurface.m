function [surface_interpolated] = interpLiaSurface(mesh_x, mesh_y)
    data = load('Data/shape/kauq/KG_surface_1900b.txt');
    x = data(:, 1);
    y = data(:, 2);
    topo = data(:, 3);

    x_lin = linspace(min(x), max(x), 600);  % I think i chose 600 is arbitrarily, but sufficient
    y_lin = linspace(min(y), max(y), 600);
    [x_grid, y_grid] = meshgrid(x_lin, y_lin);
    topo_grid = griddata(x, y, topo, x_grid, y_grid);

    surface_interpolated = InterpFromGridToMesh(x_lin', y_lin', topo_grid, mesh_x, mesh_y, 0);

    %% Missing values
    % there is missing surface elevation data on the edges of the domain (set to 0) so we want to interpolate those
    % we want to avoid touching the front area so I have made an exp for that:
    not_front_area = ~ContourToNodes(mesh_x, mesh_y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_large.exp', 2);

    % Find low surface elevation everywhere but the front area, 10 meters is a buffer.
    known_surface = surface_interpolated > 10;
    pos1 = find(known_surface & not_front_area);
    missing_surface = surface_interpolated < 10;
    pos2 = find(missing_surface & not_front_area);

    % interpolate
    F = scatteredInterpolant(mesh_x(pos1), mesh_y(pos1), surface_interpolated(pos1), 'natural', 'nearest');
    val = F(mesh_x(pos2), mesh_y(pos2));
    surface_interpolated(pos2) = val;

    %% Missing values at the front
    % The 1900 front position and surface observation does not align perfectly, so there is an area
    % between front position and surface != 0 where the surface is 0. The most safe thing would be
    % to define this area in a general manner, but as there is no 0's left, except at the front, so
    % we will be able to make a boolean mask. 
    pos1 = find(surface_interpolated ~= 0);
    pos2 = find(surface_interpolated == 0);
    F = scatteredInterpolant(mesh_x(pos1), mesh_y(pos1), surface_interpolated(pos1), 'natural', 'nearest');
    val = F(mesh_x(pos2), mesh_y(pos2));
    surface_interpolated(pos2) = val;
end