function [front_area_friction, front_area_pos] = extrapolate_friction_linear(md)
    %--
    % Extrapolates smb data based on a gaussian random field. It computes the std and
    % mean from the data, but correlation length is hard-coded (determined from plot)
    % Returns area with new values in 0 areas, and the positions of the front area, 
    % and replaced value positions
    %--
    rng('default')

    %find glacier frony from earlier
    front_area_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area.exp', 2));
    friction_stat_area = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/friction_statistics.exp', 2));
    
    % get corresponding coords
    x = md.mesh.x;
    y = md.mesh.y;

    % define grid to interpolate onto
    x_aoi = linspace(min(x), max(x), 512);
    y_aoi = linspace(min(y), max(y), 512);

    md.friction.coefficient(front_area_pos) = NaN;
    
    F = scatteredInterpolant(x, y, md.friction.coefficient, 'linear', 'none');
    friction_grid = F(x_aoi, y_aoi);
    pos = isnan(friction_grid);

    J = inpaintCoherent(friction_grid, mask,'SmoothingFactor',0.5,'Radius',1);

    x = md.mesh.x(friction_stat_area);
    y = md.mesh.y(friction_stat_area);
    val = md.friction.coefficient(friction_stat_area);

    % x(front_area_pos) = [];
    % y(front_area_pos) = [];
    % val(front_area_pos) = [];

    

    front_area_friction = F(md.mesh.x, md.mesh.y);

end