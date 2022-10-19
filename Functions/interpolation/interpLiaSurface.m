function [surface_interpolated] = interpLiaSurface(mesh_x, mesh_y)

    % md = loadmodel('Models/Model_kangerlussuaq_friction.mat');
    data = load('Data/shape/kauq/KG_surface_1900b.txt');
    x = data(:, 1);
    y = data(:, 2);
    topo = data(:, 3);


    x_lin = linspace(min(x), max(x), 600);  % I think i chose 600 is arbitrarily, but sufficient
    y_lin = linspace(min(y), max(y), 600);
    [x_grid, y_grid] = meshgrid(x_lin, y_lin);
    topo_grid = griddata(x, y, topo, x_grid, y_grid);
    % imagesc(x_grid, y_grid, topo_grid); exportgraphics(gcf, 'test.png');

    surface_interpolated = InterpFromGridToMesh(x_lin', y_lin', topo_grid, mesh_x, mesh_y, 0);
    % plotmodel(md, 'data', surface_interpolated, 'figure', 111); %exportgraphics(gcf, 'thick1.png')

    not_front_area = ~ContourToNodes(mesh_x, mesh_y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_large.exp', 2);

    % fix edges
    missing_surface = surface_interpolated > 10;
    pos1 = find(missing_surface & not_front_area);
    missing_surface = surface_interpolated < 10;
    pos2 = find(missing_surface & not_front_area);

    interpolator_data = surface_interpolated(pos1);
    F = scatteredInterpolant(mesh_x(pos1), mesh_y(pos1), interpolator_data, 'natural', 'nearest');
    val = F(mesh_x(pos2), mesh_y(pos2));
    surface_interpolated(pos2) = val;

    % plotmodel(md, 'data', surface_interpolated, 'figure', 2); %exportgraphics(gcf, 'thick1.png')
    % plotmodel(md, 'data', md.geometry.surface, 'figure', 3); %exportgraphics(gcf, 'thick2.png')

    % scatter(md.mesh.x, md.mesh.y, 5, surface_interpolated); exportgraphics(gcf, 'test.png');
end