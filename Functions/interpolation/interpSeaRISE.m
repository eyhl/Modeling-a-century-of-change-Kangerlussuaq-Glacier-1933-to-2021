function out = interpSeaRISE(mesh_x, mesh_y, part)
ncdata = "/data/eigil/work/lia_kq/Data/issm_data/Greenland_5km_dev1.2.nc";
x   = ncread(ncdata,'x1');
y   = ncread(ncdata,'y1');

if strcmp(part, 'bheatflx')
    mask_data = ncread(ncdata, 'bheatflx');
    out = InterpFromGridToMesh(x, y, mask_data', mesh_x, mesh_y, nan);

elseif strcmp(part, 'surftemp')
    bed_data = ncread(ncdata, 'surftemp');
    out = InterpFromGridToMesh(x, y, bed_data', mesh_x, mesh_y, nan);

elseif strcmp(part, 'surfvelmag')
    surface_data = ncread(ncdata, 'surfvelmag');
    out = InterpFromGridToMesh(x, y, surface_data', mesh_x, mesh_y, nan);
end

end