function [surface_interpolated] = interpLiaSurface_old(mesh_x, mesh_y)

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
    % plotmodel(md, 'data', surface_interpolated, 'figure', 1); %exportgraphics(gcf, 'thick1.png')

    % surface_bedm = interpBedmachineGreenland(mesh_x, mesh_y, 'surface');

    % pos = find(surface_interpolated == 0);

    % surface_interpolated(pos) = surface_bedm(pos);

    % plotmodel(md, 'data', surface_interpolated, 'figure', 2); %exportgraphics(gcf, 'thick1.png')
    % plotmodel(md, 'data', md.geometry.surface, 'figure', 3); %exportgraphics(gcf, 'thick2.png')

    % scatter(md.mesh.x, md.mesh.y, 5, surface_interpolated); exportgraphics(gcf, 'test.png');
end