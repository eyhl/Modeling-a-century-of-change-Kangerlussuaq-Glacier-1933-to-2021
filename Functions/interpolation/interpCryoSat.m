function interpolated_surface = interpCryoSat(md)
    %INTERPITSLIVE - Interpolate itslive data onto model grid
        the_files = dir(fullfile('/data/eigil/work/lia_kq/Data/validation/cryosat/newest', '*.nc'));
        %Set years to run, start_time = first year
        years = 2010 : 2021;
    
        % extract file names and folders
        file_names = {the_files.name};
        file_folders = {the_files.folder};
        interpolated_surface = zeros(md.mesh.numberofvertices, length(years));
        times = zeros(length(file_names), 1);

        for i=1:length(file_names)
            file_path = fullfile(file_folders{i}, file_names{i});
            fprintf('Loading %s\n', file_names{i})

            % Extract the year and month substrings using regular expressions, d{4} is 4 repeated digits and d{2} is 2 repeated digits.
            tokens = regexp(file_path, '(\d{4})_(\d{2})', 'tokens');
            year_str = tokens{1}{1};
            month_str = tokens{1}{2};
            
            % Convert the year and month substrings to floats using the str2double function
            year = str2double(year_str);
            month = str2double(month_str);

            % Display the year and month as floats
            disp(['Year: ', num2str(year)]);
            disp(['Month: ', num2str(month)]);

            elevation = squeeze(ncread(file_path, 'elevation'));
            x = ncread(file_path,'x');
            y = ncread(file_path,'y');
            [X, Y] = ndgrid(x, y);

            % figure(2); imagesc(Y); colorbar();
            elevation(elevation==-2147483648) = nan;
            F = griddedInterpolant(X, Y, elevation', "nearest", "none");
            interpolated_surface(:, i) = F(md.mesh.x, md.mesh.y); 
            times(i) = year + month / 12;
            figure(1); plotmodel(md, 'data', interpolated_surface(:, i)); colorbar();

            % F = scatteredInterpolant(x, y, vel, "natural", "none");
            % interp_vel(:, year-1984) = F(md.mesh.x, md.mesh.y);
        end
        save('/data/eigil/work/lia_kq/Data/validation/cryosat/cryosat_onmesh.mat', 'interpolated_surface', 'times');
    end 