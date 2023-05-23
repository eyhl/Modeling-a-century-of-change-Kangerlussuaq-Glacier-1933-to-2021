function [surface_interpolated] = interpLiaSurface(mesh_x, mesh_y)
    missing_value_at_front = 0; 
    plotting = false;

    data = load('Data/shape/kauq/KG_surface_1933b.txt');
    x = data(:, 1);
    y = data(:, 2);
    topo = data(:, 3);
    F = scatteredInterpolant(x, y, topo, 'natural', 'none');  
    surface_interpolated = F(mesh_x, mesh_y);

    % % Find low surface elevation everywhere but the front area, 10 meters is a buffer.
    % interpolate into the front area
    known_surface_pos = ~isnan(surface_interpolated);
    missing_surface_pos = isnan(surface_interpolated);

    F = scatteredInterpolant(mesh_x(known_surface_pos), mesh_y(known_surface_pos), surface_interpolated(known_surface_pos), 'natural', 'nearest');
    surface_interpolated(find(missing_surface_pos)) = F(mesh_x(find(missing_surface_pos)), mesh_y(find(missing_surface_pos)));

    % known_surface = surface_interpolated > 10;
    % pos1 = find(known_surface);
    % missing_surface = surface_interpolated <= 10;
    % % missing_surface = isnan(surface_interpolated);
    % pos2 = find(missing_surface);

    % % % % interpolate
    % F = scatteredInterpolant(mesh_x(pos1), mesh_y(pos1), surface_interpolated(pos1), 'linear', 'nearest');
    % surface_interpolated(pos2) = F(mesh_x(pos2), mesh_y(pos2));
    

    % % x_lin = linspace(min(x), max(x), 600);  % I think i chose 600 is arbitrarily, but sufficient
    % % y_lin = linspace(min(y), max(y), 600);
    % % [x_grid, y_grid] = meshgrid(x_lin, y_lin);
    % % topo_grid = griddata(x, y, topo, x_grid, y_grid);

    % % surface_interpolated = InterpFromGridToMesh(x_lin', y_lin', topo_grid, mesh_x, mesh_y, 0);
    geoid = interpBmGreenland(mesh_x, mesh_y, 'geoid');

    ice_levelset =  ContourToNodes(mesh_x, mesh_y, '/data/eigil/work/lia_kq/Exp/first_front/first_front.exp', 2);  
    surface_interpolated(find(~ice_levelset)) = geoid(find(~ice_levelset)) + 10;

    front_1933 = load('/data/eigil/work/lia_kq/Data/shape/fronts/processed/1933.mat');
    front_1933 = front_1933.front1933;

    surface_interpolated = surface_interpolated - geoid;
    surface_interpolated(front_1933>0) = geoid(front_1933>0);

    % this is because sea surface is set to 0 in ellipsoid ref (bad choice of NaN imo), so actual sea surface ends up below 0.
    % surface_interpolated(surface_interpolated<0) = 0;
    
    % %% Missing values
    % % there is missing surface elevation data on the edges of the domain (set to 0) so we want to interpolate those
    % % we want to avoid touching the front area so I have made an exp for that:
    % not_front_area = ~ContourToNodes(mesh_x, mesh_y, '/data/eigil/work/lia_kq/Exp/fast_flow/dont_update_init_H_here_large.exp', 2);

    % % % Find low surface elevation everywhere but the front area, 10 meters is a buffer.
    % known_surface = surface_interpolated > 20;
    % pos1 = find(known_surface & not_front_area);
    % missing_surface = surface_interpolated < 20;
    % % missing_surface = isnan(surface_interpolated);
    % pos2 = find(missing_surface & not_front_area);

    % % % interpolate
    % F = scatteredInterpolant(mesh_x(pos1), mesh_y(pos1), surface_interpolated(pos1), 'natural', 'nearest');
    % val = F(mesh_x(pos2), mesh_y(pos2));
    % surface_interpolated(pos2) = val;

    % %% Missing values at the front
    % % The 1900 front position and surface observation does not align perfectly, so there is an area
    % % between front position and surface != 0 where the surface is 0. The most safe thing would be
    % % to define this area in a general manner, but as there is no 0's left, except at the front, so
    % % we will be able to make a boolean mask.
    ice_levelset =  ContourToNodes(mesh_x, mesh_y, '/data/eigil/work/lia_kq/Exp/first_front/first_front.exp', 2);
    % cond1 = surface_interpolated > missing_value_at_front;
    % cond2 = surface_interpolated <= missing_value_at_front & ice_levelset;
    % pos1 = find(cond1);
    % pos2 = find(cond2);

    % F = scatteredInterpolant(mesh_x(pos1), mesh_y(pos1), surface_interpolated(pos1), 'natural', 'nearest');
    % val = F(mesh_x(pos2), mesh_y(pos2));
    % surface_interpolated(find(~ice_levelset)) = 0;

    if plotting
        % for plotting:
        xl = [4.778, 5.132]*1e5;
        yl = [-2.3039, -2.2763]*1e6;

        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_budd.mat');
        
        figure(2);
        scatter(x, y, 50, topo, 'filled'); 
        colorbar();
        set(gca,'clim',[0 500]) 
        xlim(xl);
        ylim(yl);
        colormap('turbo');

        plotmodel(md, 'data', surface_interpolated, 'mask', cond1, 'figure', 3, 'expdisp#all', 'Exp/first_front.exp', 'xlim', xl, 'ylim', yl);
        plotmodel(md, 'data', surface_interpolated, 'mask', cond2, 'figure', 4, 'expdisp#all', 'Exp/first_front.exp', 'xlim', xl, 'ylim', yl);

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