function [field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape, gridsize)
    % [a, r] = readgeoraster('Data/validation/optical/greenland_mosaic_2019_KG.tiff');
    [a, r] = readgeoraster('Data/validation/optical/greenland_large.tiff');
    % [a, r] = readgeoraster('Data/validation/optical/tile_4_2_mosaic_15m_band8_v01.1.tif');

    xgrid = linspace(r.XWorldLimits(1), r.XWorldLimits(2), size(a, 2));
    ygrid = linspace(r.YWorldLimits(1), r.YWorldLimits(2), size(a, 1));

    % subsample satelite image
    dims = ndims(a);
    if dims > 2
        a(:, :, 4) = [];
    end

    [sat_im] = subsample_tiff(a, r, gridsize);

    [field, X, Y] = interpolate_onto_tiff(md.mesh.x, md.mesh.y, field, r, gridsize);
    [in, ~] = inpolygon(X(:), Y(:), shape.X, shape.Y); 
    field(~in) = nan;

    % subsampled grid
    xgrid = r.XWorldLimits(1):gridsize:r.XWorldLimits(2);
    ygrid = r.YWorldLimits(1):gridsize:r.YWorldLimits(2);

    sat_im = flipud(uint8(sat_im));
end