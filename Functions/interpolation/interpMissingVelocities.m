function [vel] = interpMissingVelocities(md, vel, missing_value)
    flags = find(vel == missing_value);
    neighbor_flags  = find(vel ~= missing_value);
    vel(flags) = griddata(md.mesh.x(neighbor_flags), md.mesh.y(neighbor_flags), vel(neighbor_flags), md.mesh.x(flags), md.mesh.y(flags));
end