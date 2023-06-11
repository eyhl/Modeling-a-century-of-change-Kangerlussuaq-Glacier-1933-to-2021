function [tiff, X, Y] = subsample_tiff(tiff, tiff_info, gridsize)
% Interpolate a field onto the grid of a tiff file
%
% Args:
%   x: x coordinates of field
%   y: y coordinates of field
%   field: 2D array of values to interpolate
%   tiff_info: struct with fields:
%       XWorldLimits: [1x2 double]
%       YWorldLimits: [1x2 double]
%       CellExtentInWorldX: float
%       CellExtentInWorldY: float
%
% Returns:
%   field: 2D array of interpolated values
%   X: x coordinates of interpolated values
%   Y: y coordinates of interpolated values
tiff_list = cell(1, size(tiff, 2));
for i=1:3
    % Create interpolant
    xgrid = linspace(tiff_info.XWorldLimits(1), tiff_info.XWorldLimits(2), tiff_info.RasterSize(2));
    ygrid = linspace(tiff_info.YWorldLimits(1), tiff_info.YWorldLimits(2), tiff_info.RasterSize(1));
    [X, Y] = meshgrid(xgrid,ygrid);
    F = griddedInterpolant(X', Y', double(tiff(:, :, i))', 'nearest', 'none');

    % Create grid of tiff coordinates
    xgrid = tiff_info.XWorldLimits(1):gridsize:tiff_info.XWorldLimits(2);
    ygrid = tiff_info.YWorldLimits(1):gridsize:tiff_info.YWorldLimits(2);
    [X, Y] = meshgrid(xgrid,ygrid);

    % Interpolate onto tiff grid
    tiff_list{i} = F(X', Y')';
end
tiff = cat(3, tiff_list{:});
end
