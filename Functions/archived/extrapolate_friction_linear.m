function [front_area_friction, front_area_friction2, front_area_pos] = extrapolate_friction_linear(md)
    %--
    % Extrapolates smb data based on a gaussian random field. It computes the std and
    % mean from the data, but correlation length is hard-coded (determined from plot)
    % Returns area with new values in 0 areas, and the positions of the front area, 
    % and replaced value positions
    %--
    rng('default')

    %find glacier frony from earlier
    front_area_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/1900_extrapolation_area.exp', 2));
    friction_stat_area = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/friction_statistics.exp', 2));
    
    % get corresponding coords
    x = md.mesh.x;
    y = md.mesh.y;

    x_max = 480009;
    x_min = 466839;

    y_max = -2271150;
    y_min = -2281880;

    % define square area in friction stat area
    x_small_region = linspace(x_min, x_max, 128);
    y_small_region = linspace(y_min, y_max, 128);
    [x_small_grid, y_small_grid] = meshgrid(x_small_region, y_small_region);

    % create friction interpolant
    F = scatteredInterpolant(x, y, md.friction.coefficient, 'linear', 'none');

    % interpolate onto square grid
    friction_small_region = F(x_small_grid, y_small_grid);
    min_fric = min(min(friction_small_region));
    max_fric = max(max(friction_small_region));

    friction_small_region = (friction_small_region - min_fric) / (max_fric - min_fric);

    friction_small_region = im2uint8(friction_small_region);
    front_area_friction = friction_small_region;

    % % friction in 3 color channels
    friction_small_region = repmat(friction_small_region, 1, 1, 3);

    disp(size(friction_small_region))

    % % region growing of smaller region
    front_area_friction = synthesizeTexture(friction_small_region, 0, 8, 512, 512);

    front_area_friction = (max_fric - min_fric) * front_area_friction + min_fric;
    front_area_friction2 = F(x_small_grid, y_small_grid);



    % % define grid to interpolate onto
    % x_aoi = linspace(min(x), max(x), 512);
    % y_aoi = linspace(min(y), max(y), 512);

    % md.friction.coefficient(front_area_pos) = NaN;
    
    % F = scatteredInterpolant(x, y, md.friction.coefficient, 'linear', 'none');
    % friction_grid = F(x_aoi, y_aoi);
    % pos = isnan(friction_grid);

    % J = inpaintCoherent(friction_grid, mask,'SmoothingFactor',0.5,'Radius',1);

    % x = md.mesh.x(friction_stat_area);
    % y = md.mesh.y(friction_stat_area);
    % val = md.friction.coefficient(friction_stat_area);

    % % x(front_area_pos) = [];
    % % y(front_area_pos) = [];
    % % val(front_area_pos) = [];

    

    % front_area_friction = F(md.mesh.x, md.mesh.y);

end