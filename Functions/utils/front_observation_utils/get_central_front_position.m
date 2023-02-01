function [distance_obs, distance_interp, gradient_interp, gradient_sign, time_interp] = get_central_front_position(md, flowline, validate)
    %%
    if nargin < 3
        validate = false;
    end

    lvlset = md.levelset.spclevelset;
    time_steps = size(md.levelset.spclevelset, 2);
    x = zeros(time_steps, 1);
    y = zeros(time_steps, 1);
    distance = zeros(time_steps, 1);

    for i=1:time_steps
        contours = isoline(md, lvlset(1:end-1, i));
        cx = {contours.x};
        cy = {contours.y};

        % handles ice bergs
        if length(cx) > 1
            select = zeros(length(cx), 1);
            for j=1:length(cx)
                select(j) = numel(cx{j});
            end
            [~, s] = max(select);
        else 
            s = 1;
        end
        [xi, yi, ii] = polyxpoly(cx{s}, cy{s}, flowline.x, flowline.y);
        
        % handles that 1 at index 893 wriggle that makes 3 intersections
        if length(xi)>1
            xi = xi(1);
            yi = yi(1);
        end

        flowline_before_front_x = flowline.x;
        flowline_before_front_y = flowline.y;

        tmp_x = [xi; flowline_before_front_x(ii(end)+1:end)];
        tmp_y = [yi; flowline_before_front_y(ii(end)+1:end)];

        data = [tmp_x(:),tmp_y(:)];

        % compute the chordal linear arclengths
        seglen = sqrt(sum(diff(data,[],1).^2,2));
        arclen = trapz(seglen);

        if validate
            if mod(i, 200) == 1
                figure(i)
                scatter(flowline_before_front_x(ii(end)+1), flowline_before_front_y(ii(end)+1), 30, 'r', 'filled'); hold on;
                scatter(cx{s}, cy{s}, 20, 'k')
                scatter(tmp_x, tmp_y, 50, 'g')
                title(sprintf("Distance = %f [km]", arclen/1000))
            end
        end

        distance(i) = arclen;
        x(i) = xi;
        y(i) = yi;

    end
    distance_obs = distance - distance(1); % first front as reference 0 distance

    t_front_obs = md.levelset.spclevelset(end, :);
    time_interp = [md.results.TransientSolution(:).time];
    distance_interp = interp1(t_front_obs, -distance, time_interp); % distance linear interpolated for all available times
    gradient_interp = gradient(distance_interp, time_interp);

    % remove NaNs, which occur if time 0 spc does not align with time 0 in model.
    nan_index = isnan(gradient_interp);
    if ~isempty(nan_index)
        time_interp = time_interp(~nan_index);
        distance_interp = distance_interp(~nan_index);
        gradient_interp = gradient_interp(~nan_index);
    end
    gradient_sign = gradient_interp;

    % reduce gradient to a sign function for positive and negative gradient
    gradient_sign(gradient_sign<0) = max([-1, gradient_sign(gradient_sign<0)]);
    gradient_sign(gradient_sign>0) = min([1, gradient_sign(gradient_sign>0)]);    
end