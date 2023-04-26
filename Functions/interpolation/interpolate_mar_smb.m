function [md] = interpolate_mar_smb(md, start_time, final_time, the_files)
    %%
    % usage: 
    % smb_file = Data/smb/racmo
    % the_files = dir(fullfile(smb_file))
    % md = interpolate_racmo_smb(md, 2000, 2001, the_files)
    %% out = InterpFromGridToMesh(x, y, smb(:,:,8)', md.mesh.x, md.mesh.y, 0)
    % extract file names and folders
    file_names = {the_files.name};
    file_folders= {the_files.folder};
    save_year = zeros(1, length(file_names));
    % find files corresponding to year interval
    for i=1:length(file_names)
        num = regexp(file_names{i}, '\d+', 'match');
        save_year(i) = str2int(num{end});
        if ~isempty(strfind(file_names{i}, string(start_time))) 
            start_index = i; 
        elseif ~isempty(strfind(file_names{i}, string(final_time)))
            final_index = i; 
        end
    end

    if ~exist('start_index', 'var')
        start_index = 1;
        start_time = save_year(1);
    end

    if ~exist('final_index', 'var')
        final_index = length(file_names);
        final_time = save_year(end);
    end

    file_names = file_names(start_index:final_index);
    file_folders = file_folders(start_index:final_index); 

    %Set years to run, start_time = first year
    years_of_simulation = start_time : final_time;

    %initialize surface mass balance matrix
    smb_total = zeros(md.mesh.numberofvertices, length(years_of_simulation) * 12);

    count_nan = 0;

    for year = 1 : length(years_of_simulation)
        % the variable names changes at year 1990 for some reason.
        current_year = start_time + year;
        lat_var_name = 'y';
        lon_var_name = 'x';
        smb_var_name = 'SMB';
    
        if rem((year - 1) + start_time, 10) == 0
            fprintf('interpolating smb in the %ds\n', (year - 1) + start_time)
        end 
        
        base_file_name = file_names{year};
        full_file_name = fullfile(file_folders{year}, base_file_name);
        fprintf('%s\n', full_file_name)

        %Set surface mass balance
        y  = ncread(full_file_name, lat_var_name);
        x  = ncread(full_file_name, lon_var_name);
        smb = ncread(full_file_name, smb_var_name);

        [X, Y] = ndgrid(x, y);

        F = griddedInterpolant(X, Y, smb);
        Vq = F(md.mesh.x, md.mesh.y); 
        check_nans = squeeze(Vq);
        check_nans(smb > 1e34) = NaN;
        if ~isempty(find(isnan(check_nans), 1))
            count_nan = count_nan + 1;
            fprintf('NaNs discovered in SMB!!!!!, counting = %d\n', count_nan)
            % smb = fillmissing(smb, 'linear');
        end

        smb_total(:, 1 + (year - 1) * 12 : 12 + (12 * (year - 1))) = squeeze(Vq);
    end

    missing_values = find(isnan(md.smb.mass_balance(1:end-1, :)));
    if ~isempty(missing_values)
        fprintf('NaNs discovered in years!!!!!, counting = %g\n', years_of_simulation(missing_values))
        % smb = fillmissing(smb, 'linear');
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