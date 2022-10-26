function [md] = interpolate_racmo_smb(md, start_time, final_time, the_files)
    %%
    % usage: 
    % smb_file = Data/smb/racmo
    % the_files = dir(fullfile(smb_file))
    % md = interpolate_racmo_smb(md, 2000, 2001, the_files)
    %% out = InterpFromGridToMesh(lon, lat, smb(:,:,8)', md.mesh.x, md.mesh.y, 0)

    %Set years to run, start_time = first year
    years_of_simulation = start_time : final_time;

    %initialize surface mass balance matrix
    smb_total = zeros(md.mesh.numberofvertices, length(years_of_simulation) * 12);

    % extract file names and folders
    file_names = {the_files.name};
    file_folders= {the_files.folder};

    % find files corresponding to year interval
    for i=1:length(file_names)
        if ~isempty(strfind(file_names{i}, string(start_time))) 
            start_index = i; 
        elseif ~isempty(strfind(file_names{i}, string(final_time)))
            final_index = i; 
        end 
    end

    file_names = file_names(start_index:final_index);
    file_folders = file_folders(start_index:final_index); 

    for year = 1 : length(years_of_simulation)
        % the variable names changes at year 1990 for some reason.
        current_year = start_time + year;
        if current_year >= 1991
            lat_var_name = 'y';
            lon_var_name = 'x';
            smb_var_name = 'smb_rec';
        else
            lat_var_name = 'lat';
            lon_var_name = 'lon';
            smb_var_name = 'SMB_rec';
        end

        if rem((year - 1) + start_time, 10) == 0
            fprintf('interpolating smb in the %ds\n', (year - 1) + start_time)
        end 
        
        base_file_name = file_names{year};
        full_file_name = fullfile(file_folders{year}, base_file_name);
        fprintf('%s\n', full_file_name)

        %Set surface mass balance
        lat  = ncread(full_file_name, lat_var_name);
        lon  = ncread(full_file_name, lon_var_name);
        smb = ncread(full_file_name, smb_var_name);

        [X, Y] = ndgrid(lon, lat);

        check_nans = smb;
        check_nans(smb < -1e20) = NaN;
        count_nan = 0;
        if ~isempty(find(isnan(check_nans), 1))
            count_nan = count_nan + 1;
            fprintf('NaNs discovered in SMB!!!!!, counting = %ds\n', count_nan)
            % smb = fillmissing(smb, 'linear');
        end
        clear check_nans

        F = griddedInterpolant(X, Y, smb);
        Vq = F(md.mesh.x, md.mesh.y); 
        smb_total(:, 1 + (year - 1) * 12 : 12 + (12 * (year - 1))) = squeeze(Vq);
    end

    % convert to ice equivalent per year, mmWE/month to mIE/yr
    smb_total = smb_total * 12 / 1000 * md.materials.rho_freshwater / md.materials.rho_ice;
    % time in monthtly decimal numbers starting from middle of Jan.
    smb_times = [start_time + 1/24 : 1/12 : final_time + 1];

    % fprintf("data dimension = %d, time dimension = %d", size(smb_total, 2), size(smb_times, 2));
    % set transient forcings
    md.smb.mass_balance = [smb_total; ...
                            smb_times];

end