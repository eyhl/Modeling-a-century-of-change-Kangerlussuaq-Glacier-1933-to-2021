function [x, y, temporal_avg_field, accumulated_field] = flowline_traceback(md, field, plot_flag)
    %% 
    % This function takes in a transient model struct from ISSM and backpropagates the points in time
    % following the modelled velocities.
    % Returns: points propagated back to start time

    if nargin < 2
        plot_flag = false;
    end

    %%
    % TODO: use this to implement point corrections -> then go for several points or full grid
    % extract 
    % load("/data/eigil/work/lia_kq/Results/flowlines/KG_flowlines.mat");

    % get model times
    md.results
    md.results.TransientSolution
    times = [md.results.TransientSolution.time];
    
    % flip time vector to start from 2020ish
    all_years = flip(times);
    N_times = length(all_years);
    start_time = floor(times(end));

    % domain extrema
    xmin = min(md.mesh.x); xmax = max(md.mesh.x);
	ymin = min(md.mesh.y); ymax = max(md.mesh.y);
    
    x = zeros(length(md.mesh.x), N_times);
    y = zeros(length(md.mesh.y), N_times);

    domain = ['Exp/domain/' 'Kangerlussuaq_full_basin_no_sides' '.exp'];
    coarse_md = triangle(model, domain, 1500);
    coarse_md.mesh.epsg=3413;
    accumulated_field = zeros(length(coarse_md.mesh.y), N_times);


    x(:, 1) = md.mesh.x;
    y(:, 1) = md.mesh.y;
    % interpolate to current points
    F = scatteredInterpolant(x(:, 1), y(:, 1), field, 'nearest', 'nearest');
    accumulated_field(:, 1) = F(coarse_md.mesh.x, coarse_md.mesh.y);

    Vx = flip([md.results.TransientSolution(:).Vx]')';
    Vy = flip([md.results.TransientSolution(:).Vy]')';

    decade_count = -rem(start_time, 10);
    % takes roughly 2 min for all points
    for i = 2:N_times
        if floor(all_years(i-1)) - floor(all_years(i)) == 1
            if rem(decade_count, 10) == 0
                fprintf("Propagating back through decade: %i's\n", ceil(all_years(i)) - 10)
                decade_count = 0;
            end
            decade_count = decade_count + 1;
        end
        % compute time-step
        dt = abs(all_years(i-1) - all_years(i));

        % find relevant year and average velocity for that year
        vx_yr_avg = Vx(:, i); % md.results.TransientSolution(i).Vx;
        vy_yr_avg = Vy(:, i); % md.results.TransientSolution(i).Vy;

        % interpolate current model velocities to propagating points
        v_x = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, vx_yr_avg, x(:, i-1), y(:, i-1));
        v_y = InterpFromMeshToMesh2d(md.mesh.elements, md.mesh.x, md.mesh.y, vy_yr_avg, x(:, i-1), y(:, i-1));

        % update position based on modeled velocities, update is in km
        x(:, i) = x(:, i-1) - v_x * dt; 
        y(:, i) = y(:, i-1) - v_y * dt;

        % interpolate to current points
        F = scatteredInterpolant(x(:, i), y(:, i), field, 'nearest', 'nearest');
        accumulated_field(:, i) = F(coarse_md.mesh.x, coarse_md.mesh.y);

    
    end
    
    accumulated_field(accumulated_field == 0) = NaN;

    % % take average in time and interpolate onto regular md mesh
    temporal_avg_field = mean(accumulated_field, 2, 'omitnan');
    temporal_avg_field(isnan(temporal_avg_field)) = 0;

    temporal_avg_field = InterpFromMeshToMesh2d(coarse_md.mesh.elements, coarse_md.mesh.x, coarse_md.mesh.y, temporal_avg_field, md.mesh.x, md.mesh.y);

    if plot_flag
        plotmodel(md, 'data', md.initialization.vel,...
            'mask', (md.mask.ice_levelset<1),...
            'xlim', [xmin, xmax], ...
            'ylim', [ymin, ymax], ...
            'caxis', [0,10000])
        hold on

        plot(x(:, end), y(:, end), 'k+', 'Linewidth', 1.5);
    end
end