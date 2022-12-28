function [front_area_friction, front_area_pos] = extrapolate_friction_const(md)
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
    x_q = md.mesh.x(front_area_pos);
    y_q = md.mesh.y(front_area_pos);
    
    front_area_friction =  quantile(md.friction.coefficient(friction_stat_area), [.25]);
end