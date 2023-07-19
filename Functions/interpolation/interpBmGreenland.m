function out = interpBmGreenland(mesh_x, mesh_y, part)
ncdata = "/home/eyhli/IceModeling/work/lia_kq/Data/greenland_bedmachine/bedmachine_nc/BedMachineGreenland-2021-04-20.nc";
x_bm = double(ncread(ncdata, 'x'));
y_bm = flipud(double(ncread(ncdata, 'y')));

if strcmp(part, 'mask')
    mask_data = double(ncread(ncdata, 'mask'));
    out = InterpFromGridToMesh(x_bm, y_bm, flipud(mask_data'), mesh_x, mesh_y, nan);

elseif strcmp(part, 'bed')
    bed_data = double(ncread(ncdata, 'bed'));
    out = InterpFromGridToMesh(x_bm, y_bm, flipud(bed_data'), mesh_x, mesh_y, nan);

elseif strcmp(part, 'surface')
    surface_data = double(ncread(ncdata, 'surface'));
    out = InterpFromGridToMesh(x_bm, y_bm, flipud(surface_data'), mesh_x, mesh_y, nan);

elseif strcmp(part, 'geoid')
    surface_data = double(ncread(ncdata, 'geoid'));
    out = InterpFromGridToMesh(x_bm, y_bm, flipud(surface_data'), mesh_x, mesh_y, nan);
end

end