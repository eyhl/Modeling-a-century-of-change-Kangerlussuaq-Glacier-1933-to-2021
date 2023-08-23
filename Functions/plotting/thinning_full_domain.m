% masks
oceanmask = md.results.TransientSolution(end).MaskIceLevelset>0;
mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
bed_rock_mask = mask == 1;
mask = bed_rock_mask | oceanmask;

axs = 1e6 .* [0.2731    0.5222   -2.3659   -2.0644];

% remove front area with overlap
domain_path = '/home/eyhli/IceModeling/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_large.exp';
domain_mask = ContourToNodes(md.mesh.x, md.mesh.y, domain_path, 2); 
mask = mask | domain_mask;

% model
surf = md.geometry.surface;
time = [md.results.TransientSolution.time];
t2003 = find(time >= 2003);
thinning = md.results.TransientSolution(end).Thickness - md.results.TransientSolution(t2003(1)).Thickness;
thinning(mask) = NaN;

% observations
t = readtable('/home/eyhli/IceModeling/work/lia_kq/Data/validation/altimetry/thinning_icesat2/Thinning_KG_2003-2021.txt');
[x, y] = ll2xy(t.Var2, t.Var1, 1);
thin = t.Var3;
F = scatteredInterpolant(x, y, thin, 'natural', 'nearest');
observed_thinning = F(md.mesh.x, md.mesh.y);

% plot
shape = shaperead('Exp/domain/plotting_present_domain.shp');
gridsize = 100;


% [intD, meanD, areas] = integrateOverDomain(md, thinning, mask);

% % save section data as file 
% disp('Saving section data as file...')
% save('thinning_error_full_domain.mat', 'intD', 'meanD', 'areas');


thinningA = thinning - observed_thinning;
thinningA(mask) = NaN;
[secA, sat_imA, XA, YA, xgridA, ygridA] = align_to_satellite_background(md, thinningA, shape, gridsize);

% per year
secA = secA / 18;

[intD, meanD, areas] = integrateOverDomain(md, thinningA, mask);

% save section data as file 
disp('Saving section data as file...')
save('thinning_error_full_domain.mat', 'intD', 'meanD', 'areas');

%% ----------- THINNING t-------------
f = figure(992);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgridA, ygridA, sat_imA);
hold on;
p1 = pcolor(XA, YA, secA);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',1)
colormap(redblue);
caxis([-8 8]);
c = colorbar();
c.Label.String = 'Thinning error [m/yr]';
%c.Label.String = 'Thinning 2003-2021 [m]';
c.Label.Position = [3.4, 0];
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
%set(gcf,'Position',[142,407,1200,852]);

% obj = scalebar(hax2); %default, recommanded

% % % % ---Command support---
% % obj.Position = [4.6e+05 -2.29e+06];              %X-Length, 15.
% % obj.XLen = 10000;              %X-Length, 15.
% % obj.YLen = 20000;              %X-Length, 15.
% % obj.XUnit = 'km';            %X-Unit, 'm'.
% % obj.YUnit = 'km';            %X-Unit, 'm'.
% % % obj.Position = [55, -0.6];  %move the whole SCALE position.
% % obj.hTextX_Pos = [1, -15.0e3]; %move only the LABEL position
% % obj.hTextY_Pos = [-4e3, 0.16]; %SCALE-Y-LABEL-POSITION
% % obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
% % obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
% % obj.Color = 'k';             %'k'(default), 'w'
% % % legend('', 'Flowline', '', '', '', '', 'Location', 'NorthWest')

