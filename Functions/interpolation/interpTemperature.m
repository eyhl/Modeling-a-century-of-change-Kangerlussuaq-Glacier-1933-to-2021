function [temperature_field] = interpTemperature(md)
    temp_md = loadmodel('Data/temperature/ISMIP6Greenland_save2d.mat'); 
    temperature_field = InterpFromMeshToMesh2d(temp_md.mesh.elements, temp_md.mesh.x, temp_md.mesh.y, temp_md.results.temperature, md.mesh.x, md.mesh.y);
end