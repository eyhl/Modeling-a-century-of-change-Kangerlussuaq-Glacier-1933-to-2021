% masks
oceanmask = md.results.TransientSolution(end).MaskIceLevelset>0;
mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
bed_rock_mask = mask == 1;
mask = bed_rock_mask & oceanmask;

% model
surf = md.geometry.surface;
time = [md.results.TransientSolution.time];
t2003 = find(time >= 2003);
thinning = md.results.TransientSolution(end).Thickness - md.results.TransientSolution(t2003(1)).Thickness;
thinning(mask) = NaN;

% observations
t = readtable('/data/eigil/work/lia_kq/Data/validation/altimetry/thinning_icesat2/Thinning_KG_2003-2021.txt');
[x, y] = ll2xy(t.Var2, t.Var1, 1);
thin = t.Var3;
F = scatteredInterpolant(x, y, thin, 'natural', 'nearest');
observed_thinning = F(md.mesh.x, md.mesh.y);

% plot
shape = shaperead('Exp/domain/plotting_present_domain.shp');
gridsize = 200;

% compute section means
intD = zeros(5,1);
meanD = zeros(5,1);
areas = zeros(5,1);

[intD(1), meanD(1), areas(1)] = integrateOverDomain(md, thinning, surf>1000 | mask);
[intD(2), meanD(2), areas(2)] = integrateOverDomain(md, thinning, surf<1000 | surf>1500 | mask);
[intD(3), meanD(3), areas(3)] = integrateOverDomain(md, thinning, surf<1500 | surf>2000 | mask);
[intD(4), meanD(4), areas(4)] = integrateOverDomain(md, thinning, surf<2000 | surf>2500 | mask);
[intD(5), meanD(5), areas(5)] = integrateOverDomain(md, thinning, surf<2500 | mask);

% save section data as file 
disp('Saving section data as file...')
save('section_thinning_model.mat', 'intD', 'meanD', 'areas');


thinningA = thinning;
thinningA(surf>1000) = NaN;
[secA, ~, ~, ~, ~, ~] = align_to_satellite_background(md, thinning, shape, gridsize);

thinningB = thinning;
thinningB(surf<1000 | surf>1500) = NaN;
[secB, ~, ~, ~, ~, ~] = align_to_satellite_background(md, thinning, shape, gridsize);

thinningC = thinning;
thinningC(surf<1500 | surf>2000) = NaN;
[secC, ~, ~, ~, ~, ~] = align_to_satellite_background(md, thinning, shape, gridsize);

thinningD = thinning;
thinningD(surf<2000 | surf>2500) = NaN;
[secD, ~, ~, ~, ~, ~] = align_to_satellite_background(md, thinning, shape, gridsize);

thinningE = thinning;
thinningE(surf<2500) = NaN;
[secE, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, thinning, shape, gridsize);



%% ----------- THINNING -------------
f = figure(992);
subplot(5,2,1);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secA);                  
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

subplot(5,2,2);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secB);                  
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

subplot(5,2,3);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secC);                  
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

subplot(5,2,4);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secD);                  
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

subplot(5,2,5);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secE);                  
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


%% ---------------------------------- DIFFERENCE ------------------------------------
thinning = thinning - observed_thinning;

% compute section means
intD = zeros(5,1);
meanD = zeros(5,1);
areas = zeros(5,1);

[intD(1), meanD(1), areas(1)] = integrateOverDomain(md, thinning, surf>1000 | mask);
[intD(2), meanD(2), areas(2)] = integrateOverDomain(md, thinning, surf<1000 | surf>1500 | mask);
[intD(3), meanD(3), areas(3)] = integrateOverDomain(md, thinning, surf<1500 | surf>2000 | mask);
[intD(4), meanD(4), areas(4)] = integrateOverDomain(md, thinning, surf<2000 | surf>2500 | mask);
[intD(5), meanD(5), areas(5)] = integrateOverDomain(md, thinning, surf<2500 | mask);

% save section data as file 
disp('Saving section model error...');
save('section_thinning_error.mat', 'intD', 'meanD', 'areas');


thinningA = thinning;
thinningA(surf>1000) = NaN;
[secA, ~, ~, ~, ~, ~] = align_to_satellite_background(md, thinning, shape, gridsize);

thinningB = thinning;
thinningB(surf<1000 | surf>1500) = NaN;
[secB, ~, ~, ~, ~, ~] = align_to_satellite_background(md, thinning, shape, gridsize);

thinningC = thinning;
thinningC(surf<1500 | surf>2000) = NaN;
[secC, ~, ~, ~, ~, ~] = align_to_satellite_background(md, thinning, shape, gridsize);

thinningD = thinning;
thinningD(surf<2000 | surf>2500) = NaN;
[secD, ~, ~, ~, ~, ~] = align_to_satellite_background(md, thinning, shape, gridsize);

thinningE = thinning;
thinningE(surf<2500) = NaN;
[secE, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, thinning, shape, gridsize);



%% ----------- THINNING -------------
subplot(5,2,6);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secA);                  
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

subplot(5,2,7);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secB);                  
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

subplot(5,2,8);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secC);                  
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

subplot(5,2,9);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secD);                  
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

subplot(5,2,10);
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgrid, ygrid, sat_im);

hold on;
p1 = pcolor(X, Y, secE);                  
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

set(gcf,'PaperType','A4');
print('supplement_thinning_sections.pdf', '-dpdf', '-bestfit')