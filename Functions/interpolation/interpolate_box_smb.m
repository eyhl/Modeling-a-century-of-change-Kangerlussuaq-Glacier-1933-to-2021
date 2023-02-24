function [md] = interpolate_box_smb(md, start_time, final_time, smb_file)
    ncbox=smb_file;
    
    %Set surface mass balance
    lat  = ncread(ncbox, 'lat');
    lon  = ncread(ncbox, 'lon');
    smbbox = ncread(ncbox, 'MassFlux');
    [x_box, y_box] = ll2xy(lat, lon, +1, 39, 71);
    x_box = double(x_box);
    y_box = double(y_box);
    smbbox = double(smbbox);

    %convert mesh x,y into the Box projection
    % I guess this is a work-around because there is no xy2xy() function.
    % [md.mesh.lat, md.mesh.long]  = xy2ll(md.mesh.x, md.mesh.y, +1, 39, 71);
    % [xi, yi]= ll2xy(md.mesh.lat,md.mesh.long,+1, 45, 70);

    [LAT,  LON] = xy2ll(md.mesh.x, md.mesh.y, +1, 45, 70);      % (x,y)[45, 70] to (lat,lon)[39, 71] (md geometry)
    [x_proj, y_proj] = ll2xy(LAT, LON  , +1, 39, 71);             % (lat,lon)[39, 71] to (x,y)[39, 71]
    % smb = InterpFromGrid(x_box, y_box, box_smb, x_proj, y_proj);    % interpolate in box reference

    %Set years to run
    start_year = start_time;
    years_of_simulation = start_time:final_time;

    %initialize surface mass balance matrix
    smb = nan * ones(md.mesh.numberofvertices, length(years_of_simulation) * 12);

    disp('Interpolating box smb to grid');
    %Interpolate and set surface mass balance
    for year=years_of_simulation
        if rem(year, 10) == 0
            fprintf('interpolating smb in the %ds\n', year)
        end
        for month=1:12
            smb_month_data = squeeze(smbbox(:, :, month, year - (start_year - 1)));
            % F = scatteredInterpolant(x_smb(:), y_smb(:), smb_month_data(:), 'nearest');
            % smb_mo = F(xi, yi);
            F = scatteredInterpolant(x_box(:), y_box(:), smb_month_data(:), 'nearest');
            smb_mo = F(x_proj, y_proj);
            smb(:, (year - years_of_simulation(1)) * 12 + month) = smb_mo;
        end
    end

    % convert to ice equivalent per year, mmWE/month to mIE/yr
    % smb_mie = smb * 12/1000 * md.materials.rho_freshwater / md.materials.rho_ice;
    smb_mie = smb * 12/1 * 1 / md.materials.rho_ice; 

    % time in monthtly decimal numbers starting from middle of Jan.
    smb_times = [start_time + 1/24 : 1/12 : final_time + 1];

    % set transient forcings
    md.smb.mass_balance = [smb_mie; ...
                           smb_times];

end