% start_year = 2003;
% end_year = 2021;

% t = readtable('/data/eigil/work/lia_kq/Data/validation/altimetry/thinning_icesat2/Thinning_KG_2003-2021.txt');
% [x, y] = ll2xy(t.Var2, t.Var1, 1);
% thin = t.Var3;

% F = scatteredInterpolant(x, y, thin, 'natural', 'nearest');
% observed_thinning = F(md.mesh.x, md.mesh.y);

% thickness = [md.results.TransientSolution.Thickness];
% time = [md.results.TransientSolution.time];
% start_ind = find(floor(time)==start_year);
% thickness_in_interval = thickness(:, start_ind:end);
% modeled_thinning = zeros(size(thickness_in_interval, 1), 1);

% for i=2:size(thickness_in_interval, 2)
%     dh = thickness_in_interval(:, i) - thickness_in_interval(:, i-1);
%     modeled_thinning = modeled_thinning + dh;
% end

% accumulated2 = thickness_in_interval(:, end) - thickness_in_interval(:, 1);

% mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
% bed_rock_mask = mask == 2;
% mask = md.results.TransientSolution(end-1).MaskIceLevelset<0 & bed_rock_mask;
% mask = md.mask.ice_levelset<0 & bed_rock_mask;
% caxis_max = max(modeled_thinning(mask));
% caxis_min = min(observed_thinning(mask));

% shape = shaperead('Exp/domain/plotting_present_domain.shp');
% gridsize = 200;

% modeled_thinning(~mask) = NaN;
% observed_thinning(~mask) = NaN;
% difference_thinning = modeled_thinning - observed_thinning;
% difference_thinning(~mask) = NaN;

% [mt, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, modeled_thinning, shape, gridsize);
% [ot, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, observed_thinning, shape, gridsize);
% [dt, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, modeled_thinning - observed_thinning, shape, gridsize);

%% ----------- THINNING MODELED -------------
f = figure(992);
subplot(2,2,1);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, mt);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',1)
colormap('turbo');
caxis([-200 200]);
c = colorbar();
c.Label.String = 'Thinning 2003-2021 [m]';
c.Label.Position = [3.4, 0];
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([min(md.mesh.x) - 5e3 max(md.mesh.x) + 5e3]);
ylim([min(md.mesh.y) - 15e3 max(md.mesh.y) + 15e3]);
ax = gca;
ax.FontSize = 12; 
set(gcf,'Position',[142,407,1200,852]);

obj = scalebar(hax2); %default, recommanded

% % ---Command support---
obj.Position = [2.8821e+05 -2.35e+06];              %X-Length, 15.
obj.XLen = 10000;              %X-Length, 15.
obj.XUnit = 'km';            %X-Unit, 'm'.
obj.YUnit = 'km';            %X-Unit, 'm'.
% obj.Position = [55, -0.6];  %move the whole SCALE position.
obj.hTextX_Pos = [1, -10.0e3]; %move only the LABEL position
obj.hTextY_Pos = [-7.5e3, 0.16]; %SCALE-Y-LABEL-POSITION
obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
obj.Color = 'k';             %'k'(default), 'w'
% legend('', 'Flowline', '', '', '', '', 'Location', 'NorthWest')


%% ----------- THINNING OBSERVED -------------
subplot(2,2,2);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, ot);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',1)
colormap('turbo');
caxis([-200 200]);
c = colorbar();
c.Label.String = 'Thinning 2003-2021 [m]';
c.Label.Position = [3.4, 0];
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([min(md.mesh.x) - 5e3 max(md.mesh.x) + 5e3]);
ylim([min(md.mesh.y) - 15e3 max(md.mesh.y) + 15e3]);
ax = gca;
ax.FontSize = 12; 
% set(gcf,'Position',[100 100 580 450]);

% obj = scalebar(hax2); %default, recommanded

% % % ---Command support---
% obj.Position = [2.8821e+05 -2.35e+06];              %X-Length, 15.
% obj.XLen = 5000;              %X-Length, 15.
% obj.XUnit = 'km';            %X-Unit, 'm'.
% obj.YUnit = 'km';            %X-Unit, 'm'.
% % obj.Position = [55, -0.6];  %move the whole SCALE position.
% obj.hTextX_Pos = [1, -10.0e3]; %move only the LABEL position
% obj.hTextY_Pos = [-7.5e3, 0.16]; %SCALE-Y-LABEL-POSITION
% obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
% obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
% obj.Color = 'k';             %'k'(default), 'w'


%% ----------- THINNING DIFFERENCE -------------
% f2 = figure(994);
subplot(2,2,3);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, dt);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',1)
colormap('turbo');
caxis([-100 100]);
c = colorbar();
c.Label.String = 'Difference in thinning [m]';
c.Label.Position = [3.4, 0];
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([min(md.mesh.x) - 5e3 max(md.mesh.x) + 5e3]);
ylim([min(md.mesh.y) - 15e3 max(md.mesh.y) + 15e3]);
ax = gca;
ax.FontSize = 12; 
% set(gcf,'Position',[100 100 580 450]);

% obj = scalebar(hax2); %default, recommanded

% % % ---Command support---
% obj.Position = [2.8821e+05 -2.35e+06];              %X-Length, 15.
% obj.XLen = 5000;              %X-Length, 15.
% obj.XUnit = 'km';            %X-Unit, 'm'.
% obj.YUnit = 'km';            %X-Unit, 'm'.
% % obj.Position = [55, -0.6];  %move the whole SCALE position.
% obj.hTextX_Pos = [1, -10.0e3]; %move only the LABEL position
% obj.hTextY_Pos = [-7.5e3, 0.16]; %SCALE-Y-LABEL-POSITION
% obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
% obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
% obj.Color = 'k';             %'k'(default), 'w'


% histogram with normalized counts
% figure(1); clf;
subplot(2,2,4); histogram(modeled_thinning - observed_thinning, 100, 'Normalization', 'probability'); xlabel('m'); ylabel('Probability Density'); xlim([-100, 100]);

% subplot(2,2,1); histogram(modeled_thinning, 100, 'Normalization', 'probability'); title('Histogram of modelled thinning'); xlabel('m'); ylabel('count');
% xlabels = num2cell(round(linspace(min(md.mesh.x), max(md.mesh.x), 5) ./ 1000));
% ylabels = num2cell(round((min(md.mesh.y):30000:max(md.mesh.y)) ./ 1000));

% figure(2); clf;
% subplot(2,2,4); histogram(modeled_thinning - observed_thinning, 100, 'Normalization', 'probability'); xlabel('m'); ylabel('Probability Density'); xlim([-150, 150]);
% plotmodel(md, 'data', modeled_thinning, 'mask', mask, 'subplot', [2,2,1], 'xticklabel', xlabels, 'yticklabel', ylabels, 'xlabel', 'X [km]', 'ylabel', 'Y [km]', 'caxis', [-150, 150], 'FontSize#all', 11);
% h = colorbar();
% title(h, '[m]'); 
% plotmodel(md, 'data', observed_thinning, 'mask', mask, 'subplot', [2,2,2], 'xticklabel', xlabels, 'yticklabel', ylabels, 'xlabel', 'X [km]', 'ylabel', 'Y [km]', 'caxis', [-150, 150], 'FontSize', 11);
% h = colorbar();
% title(h, '[m]');
% plotmodel(md, 'data', modeled_thinning - observed_thinning, 'mask', mask, 'subplot', [2,2,3], 'xticklabel', xlabels, 'yticklabel', ylabels, 'xlabel', 'X [km]', 'ylabel', 'Y [km]', 'caxis', [-150, 150], 'FontSize', 11);
% h = colorbar();
% title(h, '[m]');

% plotmodel(md, 'data', modeled_thinning, 'mask', mask, 'xticklabel', xlabels, 'yticklabel', ylabels, 'xlabel', 'X [km]', 'ylabel', 'Y [km]', 'caxis', [-250, 250], 'FontSize#all', 11, 'fiure', 1);
