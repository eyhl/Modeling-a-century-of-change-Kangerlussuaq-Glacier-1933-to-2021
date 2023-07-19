function [md] = fill_in_texture(md, friction_simulation_file)
    % load Bedmachine data for bed topo estimate
    ncdata = "/home/eyhli/IceModeling/work/lia_kq/Data/greenland_bedmachine/bedmachine_nc/BedMachineGreenland-2021-04-20.nc";

    % load extrapolate/simulated friction coefficient
    S = load(friction_simulation_file);
    synthetic_friction = S.synthetic_friction;

    bed_data = double(ncread(ncdata, 'bed'));
    x_bm = double(ncread(ncdata, 'x'));
    y_bm = flipud(double(ncread(ncdata, 'y')));
    bed = InterpFromGridToMesh(x_bm, y_bm, flipud(bed_data'), md.mesh.x, md.mesh.y, nan);

    % weigh by bed, 0 is deepest
    factor = 1.8; % manually chosen based on resulting velocity from forward pass.
    bed_normalised = factor * (1 - (bed - max(bed)) / (min(bed) - max(bed)));

    % find the nodes within the area where we want to extrapolate friction coefficient
    pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/1900_extrapolation_area.exp', 2));

    % find corner positions of
    min_x = min(md.mesh.x(pos));
    max_x = max(md.mesh.x(pos));

    min_y = min(md.mesh.y(pos));
    max_y = max(md.mesh.y(pos));

    synth_friction_c = synthetic_friction;

    x_synth = linspace(min_x, max_x, size(synth_friction_c, 2));
    y_synth = linspace(min_y, max_y, size(synth_friction_c, 1));
    
    extrapolated_friction_c = InterpFromGridToMesh(x_synth', y_synth', flipud(synth_friction_c), md.mesh.x(pos), md.mesh.y(pos), nan);

    md.friction.coefficient(pos) = extrapolated_friction_c .* bed_normalised(pos);
end