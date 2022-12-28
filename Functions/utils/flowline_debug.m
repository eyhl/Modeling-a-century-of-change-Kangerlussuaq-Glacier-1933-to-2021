function [flowline] = flowline_debug(md, x0, y0)
    % x0 = [507680];
    % y0 = [-2297520];
    xmin = 361900; xmax = 510001;
	ymin = -2310000; ymax = -2160900;
    plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'log', 10, 'caxis', [1 8e4], ...
            'mask', (md.mask.ice_levelset<1), ...
            'figure', 4, ...
            'xlim', [xmin, xmax], 'ylim', [ymin, ymax]); hold on
    scale = 1;
    index = md.mesh.elements;
    x = md.mesh.x;
    y = md.mesh.y;
    vel = md.results.StressbalanceSolution.Vel .* scale;
    u = md.results.StressbalanceSolution.Vx .* scale;
    v = md.results.StressbalanceSolution.Vy .* scale;

    flowline = flowlines(index, x, y, u, v, x0, y0, 'maxiter', 200);
    flowline
    plot(flowline.x, flowline.y, 'Linewidth', 1.5, 'LineStyle', 'none', 'Marker', 'x');
end