% # TODO: 
% # 1. Add a colorbar with dates
% # 2. Cut away domain shape
% axes = 1e6 .* [0.487655430862443   0.514041014500153  -2.306075792064243  -2.283304319490709];
top = 1e6 .* [0.501337226855347  -2.293433404185838]; % top fjord point
bottom = 1e6 .* [0.503052804046823  -2.298940665694458]; % bottom fjord point

% Load the shapefile using the shapefile library
shapefile = 'Data/shape/fronts/processed/vermassen.shp';
S = shaperead(shapefile);

% remove 1900 and 1932 fronts:
S(1:2) = [];
numPolygons = numel(S);

% filter points outside fjord
for i = 1:numPolygons
    x = S(i).X;
    y = S(i).Y;
    distance = sqrt((x - bottom(1)).^2 + (y - bottom(2)).^2);
    [val, index] = min(distance);

    % index_1 = find(x > top(1) & y > top(2));
    % index_2 = find(x > bottom(1) & y < bottom(2));
    S(i).X(1:index) = [];
    S(i).Y(1:index) = [];

    S(i).X(end-10:end) = [];
    S(i).Y(end-10:end) = [];
end
            
% Extract the polygon coordinates and dates
polygons = cell(numPolygons, 1);
dates = datetime(zeros(numPolygons, 1), 0, 0);
for i = 1:numPolygons
    polygons_x{i} = S(i).X;
    polygons_y{i} = S(i).Y;
    dates(i) = datetime(S(i).Date); % Convert string date to numerical representation
end

% Normalize dates between 0 and 1
minDate = min(dates);
maxDate = max(dates);
datesNormalized = (dates - minDate) / (maxDate - minDate);

% Create decreasing alpha values
alpha_list = rescale(exp(linspace(1, 0, length(datesNormalized))), 0.3, 0.8);

% Create double colormap
n_cmaps = 2;
bits = 256 * n_cmaps;
n_colors = ceil(bits * 0.55);
col1 = copper(n_colors);
col2 = turbo(bits - n_colors);
cmap = cat(1, col1, col2);

%% --------------  After-1985 ------------------
% Plot the polygons with lines colored from the colormap based on dates
jets_rgb = jet(numPolygons);
% figure(11);
hold on;
for i = 5:numPolygons
    color = cmap2rgb(datesNormalized(i), cmap);
    color = cat(2, color, alpha_list(i));
    line(polygons_x{i}, polygons_y{i}, 'Color', color);
end

%% --------------  Pre-1985 ------------------
% Plot the first 5 polygons with thicker lines, and on top of the other lines

front_text_positions = 1e6 .* [[0.502877736700839 + 0.0003,  -2.298891691182671 + 0.0004]; ...
                               [0.495629104131232 - 0.0030,  -2.297794533907547 - 0.0003]; ...
                               [0.498357769238925 + 0.0002,  -2.293461077623015 + 0.0004]; ...
                               [0.495629104131232 - 0.0010,  -2.297794533907547 - 0.0009]; ...
                               [0.498017529657039 - 0.0015,  -2.298202624219884 - 0.0019]];  % 0.497906152280591 + 0.0004,  -2.295881278883940

front_text = {'1933', '1966', '1972', '1972', '1981'};


line_thickness = [2, 3, 3, 3, 3];
for i = 1:5
    color = cmap2rgb(datesNormalized(i), cmap);
    color = cat(2, color);
    line(polygons_x{i}, polygons_y{i}, 'Color', color, 'LineWidth', line_thickness(i));
    text(front_text_positions(i, 1), front_text_positions(i, 2), front_text{i}, 'FontSize', 9, 'Color', color, 'FontWeight', 'bold');
    % if i == 4
    %     text(front_text_positions(i, 1), front_text_positions(i, 2), front_text{i}, 'FontSize', 9, 'Color', color, 'FontWeight', 'bold', 'BackgroundColor', [0.9, 0.9, 0.9, 0.8]);
    % end
end

% Create colorbar with date labels
colormap(cmap);
% caxis([minDate maxDate]); % Set colorbar limits to match the date range
cb = colorbar;
cb.Label.String = 'Year';
cb.Label.FontSize = 12;
cb.Ticks = linspace(0, 1, 14); % Adjust the number of colorbar ticks as needed
cb.TickLabels = cellstr(datestr(linspace(minDate, maxDate, 14), 'yyyy')); % Format the tick labels as desired
cb.FontSize = 11;


