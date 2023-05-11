function [interp_data] = interpToFlowline(x_data, y_data, data, x_flowline, y_flowline)
% Interpolate data to a flowline
% x, y: flowline coordinates
% data: data to be interpolated
% interp_data: interpolated data
% distance: distance along the flowline

% get the distance along the flowline
% distance = cumsum([0; sqrt((x_flowline(2:end) - x_flowline(1:end-1)) .^ 2 + (y_flowline(2:end) - y_flowline(1:end-1)) .^ 2)]') / 1000;
% get the distance along the flowline from the calving front side
% distance = distance + (100 - distance(end));
% interpolate the data onto the flowline
F = scatteredInterpolant(x_data, y_data, data, 'natural', 'none');
interp_data = F(x_flowline, y_flowline);
end