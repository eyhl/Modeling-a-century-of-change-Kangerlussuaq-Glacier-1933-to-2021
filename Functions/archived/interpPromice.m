function [vel, vel_x, vel_y] = interpPromice(mesh_x, mesh_y)
% Get velocities (Note: You can use ncdisp('file') to see an ncdump)
ncdata = '/data/eigil/work/lia_kq/Data/promice/IV_20180423_20180517.nc';
days_per_year = 365.25;

% velocities in m/day
vx = ncread(ncdata,'land_ice_surface_easting_velocity') * days_per_year;
vy = ncread(ncdata,'land_ice_surface_northing_velocity') * days_per_year;
x   = (ncread(ncdata,'x'));
y   = flipud(ncread(ncdata,'y'));

% Interpolate velocities onto coarse mesh
vel_x=InterpFromGridToMesh(x, y, vx', mesh_x, mesh_y, 0);
vel_y=InterpFromGridToMesh(x, y, vy', mesh_x, mesh_y, 0);

%[velx, vely]=interpJoughinCompositeGreenland(md.mesh.x, md.mesh.y);
vel  = sqrt(vel_x.^2 + vel_y.^2);
end