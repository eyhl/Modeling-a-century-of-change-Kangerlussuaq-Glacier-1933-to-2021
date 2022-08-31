function [surface_interpolated] = interp2021Surface(md)
%  TODO: need to deliniate cliffs and nunataks and set nodes to surface 2007
    mesh_x = md.mesh.x;
    mesh_y = md.mesh.y;

    data = load('Data/surfaces/Elevation_KG_2021.txt');
    x = data(:, 1);
    y = data(:, 2);
    topo = data(:, 3);

    % figure(1);
    % scatter(x, y, 5, topo); colorbar()

    x_lin = linspace(min(x), max(x), 1000);  % I think i chose 600 is arbitrarily, but sufficient
    y_lin = linspace(min(y), max(y), 1000);
    % [x_grid, y_grid] = meshgrid(x_lin, y_lin);
    F = scatteredInterpolant(x, y, topo, 'linear', 'none');
    % topo_grid = griddata(x, y, topo, x_grid, y_grid);
    surface_interpolated = F(mesh_x, mesh_y);
    % figure(2);
    % imagesc(x_lin, y_lin, flipud(surface_interpolated)); colorbar()

    % plotmodel(md, 'data', surface_interpolated, 'figure', 3); %exportgraphics(gcf, 'thick1.png')

end