function [surface_interpolated] = interpLiaSurface(mesh_x, mesh_y)
    missing_value_at_front = 0; 
    plotting = false;

    data = load('Data/shape/kauq/KG_surface_1900b.txt');
    x = data(:, 1);
    y = data(:, 2);
    topo = data(:, 3);

    x_lin = linspace(min(x), max(x), 600);  % I think i chose 600 is arbitrarily, but sufficient
    y_lin = linspace(min(y), max(y), 600);
    [x_grid, y_grid] = meshgrid(x_lin, y_lin);
    topo_grid = griddata(x, y, topo, x_grid, y_grid);

    surface_interpolated = InterpFromGridToMesh(x_lin', y_lin', topo_grid, mesh_x, mesh_y, 0);
    geoid = interpBmGreenland(mesh_x, mesh_y, 'geoid');

    surface_interpolated = surface_interpolated - geoid;
    surface_interpolated(surface_interpolated<0) = 0;

    %% Missing values
    % there is missing surface elevation data on the edges of the domain (set to 0) so we want to interpolate those
    % we want to avoid touching the front area so I have made an exp for that:
    not_front_area = ~ContourToNodes(mesh_x, mesh_y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_large.exp', 2);

    % % Find low surface elevation everywhere but the front area, 10 meters is a buffer.
    known_surface = surface_interpolated > 10;
    pos1 = find(known_surface & not_front_area);
    missing_surface = surface_interpolated < 10;
    % missing_surface = isnan(surface_interpolated);
    pos2 = find(missing_surface & not_front_area);

    % % interpolate
    F = scatteredInterpolant(mesh_x(pos1), mesh_y(pos1), surface_interpolated(pos1), 'natural', 'nearest');
    val = F(mesh_x(pos2), mesh_y(pos2));
    surface_interpolated(pos2) = val;

    %% Missing values at the front
    % The 1900 front position and surface observation does not align perfectly, so there is an area
    % between front position and surface != 0 where the surface is 0. The most safe thing would be
    % to define this area in a general manner, but as there is no 0's left, except at the front, so
    % we will be able to make a boolean mask.
    ice_levelset =  ContourToNodes(mesh_x, mesh_y, '/data/eigil/work/lia_kq/Exp/ice_front.exp', 2);
    cond1 = surface_interpolated > missing_value_at_front;
    cond2 = surface_interpolated <= missing_value_at_front & ice_levelset;
    pos1 = find(cond1);
    pos2 = find(cond2);

    F = scatteredInterpolant(mesh_x(pos1), mesh_y(pos1), surface_interpolated(pos1), 'natural', 'nearest');
    val = F(mesh_x(pos2), mesh_y(pos2));
    surface_interpolated(pos2) = val;

    if plotting
        % for plotting:
        xl = [4.778, 5.132]*1e5;
        yl = [-2.3039, -2.2763]*1e6;

        md = loadmodel('/data/eigil/work/lia_kq/Models/accepted_models/Model_kangerlussuaq_budd.mat');
        
        figure(2);
        scatter(x, y, 50, topo, 'filled'); 
        colorbar();
        set(gca,'clim',[0 500]) 
        xlim(xl);
        ylim(yl);
        colormap('turbo');

        plotmodel(md, 'data', surface_interpolated, 'mask', cond1, 'figure', 3, 'expdisp#all', 'Exp/ice_front.exp', 'xlim', xl, 'ylim', yl);
        plotmodel(md, 'data', surface_interpolated, 'mask', cond2, 'figure', 4, 'expdisp#all', 'Exp/ice_front.exp', 'xlim', xl, 'ylim', yl);

        mask = int8(interpBmGreenland(mesh_x, mesh_y, 'mask'));
        surf_plot = surface_interpolated;
        surf_plot(mask==1) = NaN;
        % surf_plot = log(surf_plot)/log(10);
        figure(5);
        scatter3(mesh_x, mesh_y, surf_plot, 2*36, surf_plot, 'filled'); 
        colorbar();
        set(gca,'clim',[0 50]) 
        xlim(xl);
        ylim(yl);
        colormap('turbo');
    end
end