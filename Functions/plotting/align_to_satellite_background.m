function [field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape, gridsize)
    [a, r] = readgeoraster('Data/validation/optical/greenland_mosaic_2019_KG.tiff');

    xgrid = linspace(r.XWorldLimits(1), r.XWorldLimits(2), r.RasterSize(2));
    ygrid = linspace(r.YWorldLimits(1), r.YWorldLimits(2), r.RasterSize(1));

    % subsample satelite image
    a(:, :, 4) = [];
    [sat_im] = subsample_tiff(a, r, gridsize);

    [field, X, Y] = interpolate_onto_tiff(md.mesh.x, md.mesh.y, field, r, gridsize);
    [in, ~] = inpolygon(X(:), Y(:), shape.X, shape.Y); 
    field(~in) = nan;

    % subsampled grid
    xgrid = r.XWorldLimits(1):gridsize:r.XWorldLimits(2);
    ygrid = r.YWorldLimits(1):gridsize:r.YWorldLimits(2);

    sat_im = flipud(uint8(sat_im));
end