function [surface_interpolated] = interp2021Surface(md, mesh)
%  TODO: need to deliniate cliffs and nunataks and set nodes to surface 2007
    mesh_x = mesh(:, 1); % md.mesh.x;
    mesh_y = mesh(:, 2); % md.mesh.y;

    data = load('/data/eigil/work/lia_kq/Data/surfaces/Elevation_KG_2021.txt');
    x = data(:, 1);
    y = data(:, 2);
    topo = data(:, 3);

    % figure(1);
    % scatter(x, y, 5, topo); colorbar()

    x_lin = linspace(min(x), max(x), 1000);  % I think i chose 600 is arbitrarily, but sufficient
    y_lin = linspace(min(y), max(y), 1000);

    % extrapolation is necessary in some of the boundary areas very close to the edges. jj
    F = scatteredInterpolant(x, y, topo, 'linear', 'linear');

    surface_interpolated = F(mesh_x, mesh_y);

    % convert heights to reference to the geoid:
    geoid = interpBmGreenland(mesh_x, mesh_y, 'geoid');

    % NOTE: z_ellip = z_geoid + geoid. This is not super intuitive, but look at a drawing it makes sense
    surface_interpolated = surface_interpolated - geoid; 

    % figure(2);
    % imagesc(x_lin, y_lin, flipud(surface_interpolated)); colorbar()

    % plotmodel(md, 'data', surface_interpolated, 'figure', 3); %exportgraphics(gcf, 'thick1.png')
    % plotmodel(md, 'data', isnan(surface_interpolated), 'figure', 4); %exportgraphics(gcf, 'thick1.png')
end