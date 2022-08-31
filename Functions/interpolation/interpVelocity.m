function [vel, vel_x, vel_y] = interpVelocity(md, data_vx, data_vy)

    % Get velocities from geotiff
    % reintroduce data_vv if changed back
    % [A, R] = readgeoraster(data_vv);
    % pos = find(A < -1e8);
    % A(pos) = 0;
    % X_range = R.XWorldLimits(1):500:R.XWorldLimits(2);
    % Y_range = R.YWorldLimits(1):500:R.YWorldLimits(2);
    % vel = InterpFromGridToMesh(X_range', Y_range', flipud(A), md.mesh.x, md.mesh.y, 0);

    [A, R] = readgeoraster(data_vx);
    X_range = R.XWorldLimits(1):250:R.XWorldLimits(2);
    Y_range = R.YWorldLimits(1):250:R.YWorldLimits(2);
    pos = find(A < -2e8);  
    A(pos) = NaN; 
    vel_x = InterpFromGridToMesh(X_range', Y_range', flipud(A), md.mesh.x, md.mesh.y, 0);

    [A, ~] = readgeoraster(data_vy);
    pos = find(A < -2e8);  
    A(pos) = NaN; 
    vel_y = InterpFromGridToMesh(X_range', Y_range', flipud(A), md.mesh.x, md.mesh.y, 0);

    vel = sqrt(vel_x .^ 2 + vel_y .^ 2);
end