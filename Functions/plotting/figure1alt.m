% # TODO: 
% # 1. Increase font sizes
% # 1. Extend bed topography all the way to end of fjord
% # 2. Make north arrow function and add scalebar manually
% # 3. Increase resolution/gridsize and save
% # 4. Add small image of Greenland to show location manually after saving
% # 5. Collect figures in powerpoint

axs = 1e6 .* [0.422302857764172   0.510073291293409  -2.303227021597650  -2.230919592486114];
shape = shaperead('Exp/domain/plotting_present_domain.shp');
shape_large = shaperead('Exp/domain/Kangerlussuaq_full_basin_no_sides.shp');
[a, r] = readgeoraster('Data/validation/optical/greenland_mosaic_2019_KG.tiff');
gridsize = 50;

%% ----------- BED TOPOGRAPHY -------------
figure(991)
field = md.geometry.bed;
[field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape_large, gridsize);

% ax1 = subplot(2,2,1);
p0 = imagesc(xgrid, ygrid, sat_im);                  

hold on;
p1 = pcolor(X, Y, field);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',0.8)
zlimits = [min( md.geometry.bed) max(md.geometry.bed)];
demcmap(zlimits)
set(gca,'YDir','normal') 
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
c = colorbar();
c.Label.Position = [3.4, 500];
c.Label.String = 'Bedrock topography [m]';
c.Label.FontSize = 12;
c.FontSize = 12;
ax = gca;
ax.FontSize = 12; 
set(gcf,'Position',[100 100 580 450]); 


% %% ----------- VELOCITY -------------
% f2 = figure(992);
% hax2 = axes(f2);
% field = md.initialization.vel;
% [field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape, gridsize);

% % ax2 = subplot(2,2,2);
% p0 = imagesc(xgrid, ygrid, sat_im);                  

% hold on;
% p1 = pcolor(X, Y, field);                  
% set(p1, 'EdgeColor', 'none'); 
% set(p1,'facealpha',0.8)
% colormap('turbo');
% c = colorbar();
% c.Label.String = 'Surface velocity [m/yr]';
% c.Label.FontSize = 12;
% c.FontSize = 12;
% set(gca, 'YDir','normal')
% xlim([axs(1) axs(2)]);
% ylim([axs(3) axs(4)]);
% ax = gca;
% ax.FontSize = 12; 
% set(gcf,'Position',[100 100 580 450]); 

% % Call the drawNorthArrow function to overlay the north arrow
% draw_north_arrow(430000, -2.2407e6, 0.1, 2.0, 3000);
% text(430000, -2.2437e6, 'N', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontWeight', 'bold', 'Color', 'w');

% obj = scalebar(hax2); %default, recommanded

% % ---Command support---
% obj.Position = [430000, -2297000];              %X-Length, 15.
% obj.XLen = 5000;              %X-Length, 15.
% obj.XUnit = 'km';            %X-Unit, 'm'.
% obj.YUnit = 'km';            %X-Unit, 'm'.
% % obj.Position = [55, -0.6];  %move the whole SCALE position.
% obj.hTextX_Pos = [1, -3.0e3]; %move only the LABEL position
% obj.hTextY_Pos = [-3.0e3, 0.16]; %SCALE-Y-LABEL-POSITION
% obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
% obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
% obj.Color = 'w';             %'k'(default), 'w'

% % %% ----------- THICKNESS -------------
% figure(993)
% field = md.geometry.thickness;
% [field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape, gridsize);

% % ax3 = subplot(2,2,3);
% p0 = imagesc(xgrid, ygrid, sat_im);                  

% hold on;
% p1 = pcolor(X, Y, field);                  
% set(p1, 'EdgeColor', 'none'); 
% set(p1,'facealpha',0.8)
% colormap(flipud(winter));
% c = colorbar();
% c.Label.String = 'Ice thickness [m]';
% c.Label.FontSize = 12;
% c.FontSize = 12;
% caxis([0 2500])
% set(gca, 'YDir','normal')
% xlim([axs(1) axs(2)]);
% ylim([axs(3) axs(4)]);
% ax = gca;
% ax.FontSize = 12; 
% set(gcf,'Position',[100 100 580 450]); 

% %% ----------- ICE FRONTS -------------
% f4 = figure(994);
% hax4 = axes(f4);
% % front axs
% axs = 1e6 .* [0.4854, 0.508, -2.304, -2.285];

% xgrid = linspace(r.XWorldLimits(1), r.XWorldLimits(2), r.RasterSize(2));
% ygrid = linspace(r.YWorldLimits(1), r.YWorldLimits(2), r.RasterSize(1));

% % ax4 = subplot(2,2,4);
% imagesc(xgrid, ygrid, flipud(a(:,:,1:3)));
% set(gca, 'YDir','normal')

% hold on;

% plot_fronts
% xlim([axs(1) axs(2)]);
% ylim([axs(3) axs(4)]);
% ax = gca;
% ax.FontSize = 12; 
% set(gcf,'Position',[100 100 580 450]); 

% obj = scalebar(hax4); %default, recommanded

% % ---Command support---
% obj.Position = [4.870e+05 -2.3027e+06];              %X-Length, 15.
% obj.XLen = 3000;              %X-Length, 15.
% obj.YLen = 3000;              %X-Length, 15.
% obj.XUnit = 'km';            %X-Unit, 'm'.
% obj.YUnit = 'km';            %X-Unit, 'm'.
% % obj.Position = [55, -0.6];  %move the whole SCALE position.
% obj.hTextX_Pos = [1, -0.7e3]; %move only the LABEL position
% obj.hTextY_Pos = [-1.0e3, 0.16]; %SCALE-Y-LABEL-POSITION
% obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
% obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
% obj.Color = 'w';             %'k'(default), 'w'













% % build colormap for bed topography
% col1 = pink();
% col2 = summer();
% % col1 = flipud(col1);
% col2 = flipud(col2);
% col_final = cat(1, col1, col2);

% xtickl = 

% % plot bed topography with diverging colormap
% plotmodel(md, 'data', md.geometry.bed, 'caxis', [-1750 1750], 'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
%     'axis', axs, 'figure', 89, 'colorbar', 'off'); 
% % colormap(col_final); 
% demcmap(zlimits)
% set(gcf,'Position',[100 100 1500 1500]); 
% c = colorbar();
% c.Label.String = 'Bedrock topography [m]';
% xlabel('X')
% ylabel('Y')