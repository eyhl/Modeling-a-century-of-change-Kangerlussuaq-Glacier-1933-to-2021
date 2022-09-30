function [x, y] = flowline_traceback(md, plot_flag)
    %% TODO: TRY THIS
    %% - USE FLOWLINES() TO MAKE N DISTINCT FLOWLINES IN INITIAL STEP, THEY COVER ALL THE DOMAIN.
    %% - EITHER:
    %%      - INTERPOLATE ONTO FLOWLINES IN EVERY STEP, IN A CUMULATIVE MANNER THEN DIVIDE BY TIMESTEP (TIME AVEREAGE ERROR IN EACH PART OF FLOWLINE): INTERPOLATE ERRORS BACK ON MD MESH TO ACHIEVE SOME SORT OF ZONES
    %%      - TO "NORAMLIZE" WRT TO THE NUMBER OF POINTS: MAYBE USE kNN FOR EACH POINT ALONG ALL FLOWLINES: CAN BE USED TO SPREAD OUT ERROR ACROSS DOMAIN
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
    times = [md.results.TransientSolution.time];
    
    start_time = floor(times(end));
    final_time = floor(times(1));

    % domain extrema
    xmin = min(md.mesh.x); xmax = max(md.mesh.x);
	ymin = min(md.mesh.y); ymax = max(md.mesh.y);
    
    x = zeros(length(md.mesh.x), length(start_time:-1:final_time));
    y = zeros(length(md.mesh.y), length(start_time:-1:final_time));

    x(:, 1) = md.mesh.x;
    y(:, 1) = md.mesh.y;

    % flip time vector to start from 2020ish
    all_years = flip(times);

    Vx = flip([md.results.TransientSolution(:).Vx]')';
    Vy = flip([md.results.TransientSolution(:).Vy]')';

    decade_count = -rem(start_time, 10);
    % takes roughly 2 min for all points
    for i = 2:length(all_years)
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

    end
    
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