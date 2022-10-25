function [] = chooseDomain(md)
    close all
    addpath('./..');

    %% Load velocity data {{{
    % vThreashold = 50;
    % filename = '/totten_1/ModelData/Greenland/VelJoughin/IanGreenVel.mat';
    % data = load(filename);
    % vel = sqrt(data.vx.^2+data.vy.^2);
    % x = data.x_m;
    % y = data.y_m;
    %}}}

    %% plot {{{
    % v = log(vel)/log(10);
    % v(vel<vThreashold) = nan;
    % figure
    % h = imagesc(x, y, v);
    % set(gca,'YDir','normal')
    % % these ranges are larger than needed, just for exptool to draw points
    % xlim([3.1, 5.4]*1e5);
    % ylim([-2.35e6, -2.1e6]);
    % set(h, 'AlphaData', ~isnan(v))
    % colorbar;
    % colormap('jet');
    % %}}}

    %% plot friction {{{
    % CFcontour = '../merged_fronts.shp';
    %dataLevelset = ExpToLevelSet(md.mesh.x, md.mesh.y, CFcontour);
    if nargin < 1
        md = loadmodel('Models/Model_kangerlussuaq_transient.mat');
    end
    % md = loadmodel('Models/Model_kangerlussuaq_transient.mat');
    % data = double(md.geometry.thickness==10) + double(md.mask.ice_levelset==1);
    % vel = md.results.StressbalanceSolution.Vel;
    % ind = md.geometry.thickness<10;
    % scatter(md.mesh.x, md.mesh.y, 20, vel, 'filled'); hold on; scatter(md.mesh.x(ind), md.mesh.y(ind), 20, vel(ind), 'r')
    % plotmodel(md, 'data', 'mesh')
    plotmodel(md, 'data', md.results.TransientSolution(1).Vel, 'gridded', 1, 'levelset', md.mask.ice_levelset, 'figure', 1)
    % data = load('../Data/kauq/KG_surface_1900b.txt');
    % x = data(:, 1);
    % y = data(:, 2);
    % topo = data(:, 3);
    % scatter(x, y, 15, topo, 'filled');
    % caxis([0 50])
    % colorbar()
    % plotmodel(md, 'data', md.geometry.surface, 'figure', 1, 'expdisp', '../Exp/ice_inside.exp')
    % plotmodel(md, 'data', 'driving_stress', 'caxis', [0, 200], 'expdisp', 'temp.exp', 'figure', 7)
    % plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'figure', 4, 'title', 'Velocity', 'log', 10, 'caxis', [1 1.2e4]);
    % plotmodel(md, 'data', md.results.TransientSolution(5).Vel, 'figure', 4, 'title', 'Velocity', 'log', 10, 'caxis', [1 1.2e4]);

    % plotmodel(md, 'data', md.friction.C)
    % plotmodel(md, 'data', data); 
    %}}}
    plotmodel(md, 'data', md.miscellaneous.dummy.temperature_field, 'figure', 333, 'title', 'Temperature', ...
                'colorbar', 'off', 'xtick', [], 'ytick', [], ...
                'gridded', 1, 'levelset', md.mask.ice_levelset); 
                set(gca,'fontsize',12);
                set(colorbar,'visible','off')
                h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
                title(h, "Temperature field")
                colormap('turbo')


    % use exptool {{{
    % expName = CFcontour;
    % expName = 'Exp/temperature_validation.exp';
    expName = 'Exp/1900_extrapolation_area_temp.exp';
    % expName = 'Exp/thickness_misfit_aoi.exp';
    % expName = 'Exp/friction_validation.exp';
    % expName = '../Exp/1900_refine_area.exp';
    % expName = 'Exp/1900_extrapolation_area.exp';
    % expName = '../Exp/ice_inside.exp'
    % expName = '../Exp/first_front.exp';
    % expName = '../Exp/Kangerlussuaq_new.exp'
    exptool(expName)
    system(['mv ', expName, '  Exp/']);
    %}}}
end