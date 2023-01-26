function [distance, x, y] = get_central_front_position(md, flowline, validate)
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
    distance = distance - distance(1); % first front as reference 0 distance
end