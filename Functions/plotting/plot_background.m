function [xx1, yy1, xx2, yy2] = plot_background(x, y, yy)
    still_retreating = 0;
    still_advancing = 0;

    retreat_min_x = [];
    retreat_max_x = [];
    retreat_min_y = [];
    retreat_max_y = [];

    advance_min_x = [];
    advance_max_x = [];
    advance_min_y = [];
    advance_max_y = [];

    % to save correct amount of polygons
    j = 1;
    k = 1;
    for i = 1:length(x)
        if y(i) < 0
            if still_retreating == 1
                continue
            else
                % save edge
                retreat_min_x(j) = x(i);
                retreat_min_y(j) = yy(1);
                if i ~= 1
                    advance_max_x(j-1) = x(i);
                    advance_max_y(j-1) = yy(2);
                end
                still_retreating = 1;
                still_advancing = 0;
                % disp("reatreating")
                % fprintf("%.1f\n", x(i))
                j = j + 1;
            end
        else
            if still_advancing == 1
                continue
            else
                % save edge
                retreat_max_x(k) = x(i);
                retreat_max_y(k) = yy(2);
                if i ~= length(x)
                    advance_min_x(k) = x(i);
                    advance_min_y(k) = yy(1);
                end
                still_advancing = 1;
                still_retreating = 0;
                % disp("advancing")
                % fprintf("%.1f\n", x(i))
                k = k + 1;
            end
        end

    end

    xx1 = [advance_min_x; advance_min_x; advance_max_x; advance_max_x];
    yy1 = [advance_min_y; advance_max_y; advance_max_y; advance_min_y];
    % patch(xx,yy,'g',...
    %             'FaceAlpha',0.5,...
    %             'EdgeColor','none');
    % hold on;
    xx2 = [retreat_min_x; retreat_min_x; retreat_max_x; retreat_max_x];
    yy2 = [retreat_min_y; retreat_max_y; retreat_max_y; retreat_min_y];
    % patch(xx,yy,'r', 'FaceAlpha', 0.5, 'EdgeColor','none');
    % hold off