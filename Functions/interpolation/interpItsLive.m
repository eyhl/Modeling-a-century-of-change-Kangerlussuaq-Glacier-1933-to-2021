function interp_vel = interpItsLive(md)
%INTERPITSLIVE - Interpolate itslive data onto model grid
    the_files = dir(fullfile('/data/eigil/work/lia_kq/Data/validation/velocity/its_live/', '*.nc'));
    %Set years to run, start_time = first year
    years = 1985 : 2018;

    % extract file names and folders
    file_names = {the_files.name};
    file_folders = {the_files.folder};
    interp_vel = zeros(md.mesh.numberofvertices, length(years));

    for year=years
        % if rem((year - 1) + start_time, 10) == 0
        %     fprintf('interpolating smb in the %ds\n', (year - 1) + start_time)
        % end 
        fprintf('interpolating velocity in %ds\n', year)
        file_path = fullfile(file_folders{year-1984}, file_names{year-1984});
        vel = ncread(file_path, 'v');
        x = ncread(file_path,'x');
        y = ncread(file_path,'y');
        [X, Y] = ndgrid(x, y);
        % size(vel)
        % size(X)
        % size(Y)
        % figure(2); imagesc(Y); colorbar();
        vel(vel==-32767) = nan;
        F = griddedInterpolant(X, fliplr(Y), fliplr(vel));
        interp_vel(:, year-1984) = F(md.mesh.x, md.mesh.y); 
        % F = scatteredInterpolant(x, y, vel, "natural", "none");
        % interp_vel(:, year-1984) = F(md.mesh.x, md.mesh.y);
    end
    save('/data/eigil/work/lia_kq/Data/validation/velocity/its_live_onmesh.mat', 'interp_vel');
end 