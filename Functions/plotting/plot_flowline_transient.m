function [] = plot_flowline_transient(md, flowline)
    skip = 1;
    time = cell2mat({md.results.TransientSolution(:).time});
    surface = cell2mat({md.results.TransientSolution(:).Surface});
    base = cell2mat({md.results.TransientSolution(:).Base});
    vel = cell2mat({md.results.TransientSolution(:).Vel});
    ice_mask = cell2mat({md.results.TransientSolution(:).MaskIceLevelset});

    time = time(1:skip:end);
    surface = surface(:, 1:skip:end);
    base = base(:, 1:skip:end);
    vel = vel(:, 1:skip:end);
    ice_mask = ice_mask(:, 1:skip:end);

    surf_transient = {};
    base_transient = {};
    flowline_vel = NaN(length(time), 1);

    flowline_x_full = flowline.x(1:end-7);
    flowline_y_full = flowline.y(1:end-7);
    dist_from_front = flip(flowline.Xmain(1:end-7));
    dist_from_front = dist_from_front - dist_from_front(end);

    figure()
    plot(1:length(flowline.surface(1:end-7)), flowline.surface(1:end-7), 'k', 'LineWidth', 2);
    % set ( gca, 'xdir', 'reverse' );
    xlabel('Distance from front [km]')
    ylabel('Elevation [m]')
    % xticklabels(num2str(dist_from_front));
    hold on
    % legend('Surface', 'Bed', 'Base')
    cm = turbo(length(time));
    colormap(cm);

    for i=1:length(time)
        ice_x = md.mesh.x(ice_mask(:, i) < 0);
        ice_y = md.mesh.y(ice_mask(:, i) < 0);
        max_x_coordinate = max(ice_x);
        % min_y_coordinate = min(ice_y);
        keep_cond = flowline_x_full < max_x_coordinate;
        flowline_x = flowline_x_full(keep_cond);
        flowline_y = flowline_y_full(keep_cond);

        surf_transient{i} = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, surface(:, i), flowline_x, flowline_y);
        base_transient{i} = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, base(:, i), flowline_x, flowline_y);
        flowline_vel(i) = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, vel(:, i), flowline_x(end), flowline_y(end));




        % plot(surf_transient{i}, cm(i));
        % size([1:length(base_transient{i})]')
        % size([base_transient{i}]')
        plot([1:length(surf_transient{i})], [surf_transient{i}]', 'color', cm(i, :));
        plot([1:length(base_transient{i})], [base_transient{i}]', 'color', cm(i, :));
    end
    colorbar();
end