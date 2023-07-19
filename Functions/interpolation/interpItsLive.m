function [interp_vel, interp_vel_err, interp_ice_mask, interp_count] = interpItsLive(md)
%INTERPITSLIVE - Interpolate itslive data onto model grid
    the_files = dir(fullfile('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/its_live/', '*.nc'));
    %Set years to run, start_time = first year
    years = 1985 : 2018;

    % extract file names and folders
    file_names = {the_files.name};
    file_folders = {the_files.folder};
    interp_vel = zeros(md.mesh.numberofvertices, length(years));
    interp_vel_err = zeros(md.mesh.numberofvertices, length(years));
    interp_ice_mask = zeros(md.mesh.numberofvertices, length(years));
    interp_count = zeros(md.mesh.numberofvertices, length(years));


    for year=years
        % if rem((year - 1) + start_time, 10) == 0
        %     fprintf('interpolating smb in the %ds\n', (year - 1) + start_time)
        % end 
        fprintf('interpolating velocity in %ds\n', year)
        file_path = fullfile(file_folders{year-1984}, file_names{year-1984});
        vel = ncread(file_path, 'v');
        vel_err = ncread(file_path, 'v_err');
        ice_mask = ncread(file_path, 'ice');
        count = ncread(file_path, 'count');
        x = ncread(file_path,'x');
        y = ncread(file_path,'y');
        [X, Y] = ndgrid(x, y);

        F = griddedInterpolant(X, fliplr(Y), single(fliplr(ice_mask)), 'nearest', 'none');
        interp_ice_mask(:, year-1984) = logical(F(md.mesh.x, md.mesh.y));

        vel(vel==-32767) = nan;
        F = griddedInterpolant(X, fliplr(Y), fliplr(vel), 'linear', 'none');
        tmp_vel = F(md.mesh.x, md.mesh.y); 

        % set velocity to nan where ice mask is 0
        tmp_vel(~interp_ice_mask(:, year-1984)) = nan;
        interp_vel(:, year-1984) = tmp_vel;

        F = griddedInterpolant(X, fliplr(Y), fliplr(vel_err), 'linear', 'none');
        interp_vel_err(:, year-1984) = F(md.mesh.x, md.mesh.y);

        F = griddedInterpolant(X, fliplr(Y), single(fliplr(count)), 'nearest', 'none');
        interp_count(:, year-1984) = round(F(md.mesh.x, md.mesh.y));

    end
    save('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/its_live_onmesh.mat', 'interp_vel', 'interp_vel_err', 'interp_ice_mask', 'interp_count');
end 