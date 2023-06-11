function [field, X, Y] = interpolate_onto_tiff(x, y, field, tiff_info, gridsize)
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

% Create interpolant
F = scatteredInterpolant(x, y, field, 'natural', 'none');

% Create grid of tiff coordinates
xgrid = tiff_info.XWorldLimits(1):gridsize:tiff_info.XWorldLimits(2);
ygrid = tiff_info.YWorldLimits(1):gridsize:tiff_info.YWorldLimits(2);
[X, Y] = meshgrid(xgrid,ygrid);

% Interpolate onto tiff grid
field = F(X, Y);

end
