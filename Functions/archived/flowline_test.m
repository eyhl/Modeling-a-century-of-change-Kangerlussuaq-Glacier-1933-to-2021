clear
close all

glacier = 'Kangerlussuaq';
Nf = 1;

%% Load model {{{
projPath = '/data/eigil/work/lia_kq/Models/baseline/Model_kangerlussuaq_transient.mat';
saveflag = 1;
plotflag = 1;
folder = '/baseline/';
stepName = 'Param_extend';
if strcmp(glacier,'Jakobshavn')
	x0 = -1.865e5*ones(Nf, 1);
	y0 = linspace(-2.276e6, -2.2724e6, Nf);
	%y0 = linspace(-2.276e6, -2.2718e6, Nf); Nf=10
	xmin = -192000; xmax = -128000;
	ymin = -2305000; ymax = -2260000;
elseif strcmp(glacier,'Kangerlussuaq')
    % 4.8808e+05 -2.2931e+06
    % 4.9043e+05 -2.2907e+06
	x0 = linspace(4.8808e5, 4.9043e5, Nf);
	y0 = linspace(-2.2931e6, -2.2907e6, Nf);
	xmin = 361900; xmax = 519100;
	ymin = -2330100; ymax = -2160900;
elseif strcmp(glacier,'Helheim')
	x0 = 310400*ones(Nf, 1);
	y0 = linspace(-2575500, -2580000, Nf);
	xmin = -275000; xmax = 316000;
	ymin = -2586545; ymax = -2550000;
end

steps = 0;
% org=organizer('repository', [projPath, 'Models', folder], 'prefix', ['Model_' glacier '_'], 'steps', steps);
% md = loadmodel(org, stepName);
md = loadmodel('/data/eigil/work/lia_kq/Models/baseline/Model_kangerlussuaq_transient.mat');
%}}}
%% create flowlines {{{
if plotflag
    figure
    plotmodel(md, 'data', md.initialization.vel,...
        'mask', (md.mask.ice_levelset<1),...
        'xlim', [xmin, xmax], 'ylim', [ymin, ymax], 'caxis', [0,10000])
    hold on
end
% northern and southern part of the glacier
x = md.mesh.x;
y = md.mesh.y;
% [u, v]=interpJoughinCompositeGreenland(md.mesh.x,md.mesh.y);
data_vx = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vx_v1.tif';
data_vy = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vy_v1.tif';
[vel_obs, u, v] = interpVelocity(md, data_vx, data_vy);


% u = fillInNan(md, u);
% v = fillInNan(md, v);
%u = md.initialization.vx;
%v = md.initialization.vy;
index = md.mesh.elements;
% pick the seeds
if Nf == 3
	fnameList = {'S', 'C', 'N'};
else
	fnameList = strcat('F', cellstr(num2str([1:Nf]')));
end
% fnameList(1:3) = {'N', 'C', 'S'};
flowlineList = cell(length(x0), 1);
ticks = 80;
% compute the flowline
for i = 1: length(x0)
    % get the flowline
    flowlineList{i} =flowlines(index,x,y,u,v,x0(i),y0(i));
    % get the distance along the flowline
    flowlineList{i}.Xmain = cumsum([0; sqrt((flowlineList{i}.x(2:end) - flowlineList{i}.x(1:end-1)) .^ 2 + (flowlineList{i}.y(2:end) - flowlineList{i}.y(1:end-1)) .^ 2)]') / 1000;
    % get the distance along the flowline from the calving front side
    flowlineList{i}.Xmain_calving = flowlineList{i}.Xmain + (100 - flowlineList{i}.Xmain(end));
    % bedrock elevation along the flowline
    flowlineList{i}.bed = InterpFromMeshToMesh2d(md.mesh.elements,md.mesh.x,md.mesh.y,md.geometry.bed,flowlineList{i}.x,flowlineList{i}.y);
    % name
    flowlineList{i}.name = fnameList{i};
    % To visualize the flowlines
    [~,I] = min(abs(flowlineList{i}.Xmain-ticks));
    if plotflag
        plot(flowlineList{i}.x, flowlineList{i}.y, 'Linewidth', 1.5);
        plot(flowlineList{i}.x(I), flowlineList{i}.y(I), 'ko', 'Linewidth', 1.5);
    end
end

if plotflag
	hold on
	plot(x0, y0, '*')
end
%}}}
%% Save data{{{
if saveflag
    save(['/data/eigil/work/lia_kq/Results/flowlines/KG_flowlines.mat'], 'x0', 'y0', 'flowlineList');
end
%}}}
%% plot {{{
if plotflag
	figure(2)
	for i = 1: length(x0)
	    plot(flowlineList{i}.Xmain, flowlineList{i}.bed);
	    hold on
	end
	% xlim([72, 95])
end%}}}