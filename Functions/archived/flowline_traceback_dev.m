function [x, y, save_vel] = flowline_traceback_dev(md)
    % TODO: use this to implement point corrections -> then go for several points or full grid
    load("/home/eyhli/IceModeling/work/lia_kq/Results/flowlines/KG_flowlines.mat");

    times = [md.results.TransientSolution.time];
    
    start_time = floor(times(end));
    final_time = floor(times(1));

    Nf = 100;

    x0 = linspace(4.8808e5, 4.9043e5, Nf);
	y0 = linspace(-2.2931e6, -2.2907e6, Nf);
    xmin = 361900; xmax = 519100;
	ymin = -2330100; ymax = -2160900;
    
    x = zeros(Nf, length(start_time:-1:final_time));
    y = zeros(Nf, length(start_time:-1:final_time));

    x(:, 1) = x0;
    y(:, 1) = y0;

    % all_years = start_time:-1:final_time;
    all_years = flip(times);

    Vx = flip([md.results.TransientSolution(:).Vx]')';
    Vy = flip([md.results.TransientSolution(:).Vy]')';

    save_vel = zeros(Nf, length(start_time:-1:final_time), 1);

    decade_count = -rem(start_time, 10);

    for i = 2:length(all_years)
        if floor(all_years(i-1)) - floor(all_years(i)) == 1
            if rem(decade_count, 10) == 0
                fprintf("Propagating back through decade: %i's\n", ceil(all_years(i)) - 10)
                decade_count = 0;
            end
            decade_count = decade_count + 1;
        end

        dt = abs(all_years(i-1) - all_years(i));
        % find relevant year and average velocity for that year
        % year_indeces = find(times < all_years(i-1) & times > all_years(i));
        % vx_yr_avg = mean([md.results.TransientSolution(year_indeces).Vx], 2, 'omitnan');
        % vy_yr_avg = mean([md.results.TransientSolution(year_indeces).Vy], 2, 'omitnan');
        vx_i = Vx(:, i); % md.results.TransientSolution(i).Vx;
        vy_i = Vy(:, i); % md.results.TransientSolution(i).Vy;

        % disp(year_indeces)
        v_x = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, vx_i, x(:, i-1), y(:, i-1));
        v_y = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, vy_i, x(:, i-1), y(:, i-1));

        x(:, i) = x(:, i-1) - v_x * dt; % multiplied by 1 yr, to fix units
        y(:, i) = y(:, i-1) - v_y * dt;

        save_vel(:, i) = sqrt(v_x.^2 + v_y.^2);
    end

    figure(111)
    plotmodel(md, 'data', md.initialization.vel,...
        'mask', (md.mask.ice_levelset<1),...
        'xlim', [xmin, xmax], ...
        'ylim', [ymin, ymax], ...
        'caxis', [0,10000])
    hold on

    plot(x, y, 'k+', 'Linewidth', 1.5);
    plot(flowlineList{1}.x, flowlineList{1}.y, 'Linewidth', 1.5);
end