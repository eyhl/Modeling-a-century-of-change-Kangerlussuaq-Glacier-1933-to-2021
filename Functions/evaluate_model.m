function [md] = evaluate_model(md, folder, plot_options)
    save_path = folder;
    
    if find(strcmp(plot_options, 'volume'))
        dt = 1/12;
        % md = loadmodel('Models/Model_kangerlussuaq_transient.mat');
        start_time = md.smb.mass_balance(end, 1);
        final_time = md.smb.mass_balance(end, end);

        %% Volume plot
        vol = cell2mat({md.results.TransientSolution(:).IceVolume});
        vol_times = cell2mat({md.results.TransientSolution(:).time});
        figure(1);
        plot(vol_times, vol / (1e9), '-r');
        title('Ice Volume, RACMO')
        ylabel('Volume [km^3]')
        xlim([1897, 2023])
        % ylim([2.32e4 2.48e4])
        saveas(gcf, fullfile(save_path, 'ice_volume.png'))

        % % Diagnostics
        % smb_data = md.miscellaneous.dummy.smb_anomaly;

        % % get areas of all elements
        % mesh_areas = GetAreas(md.mesh.elements, md.mesh.x, md.mesh.y);

        % % integrated smb spatially
        % smb_anomaly = zeros(1, size(smb_data, 2));
        % for i=1:size(smb_data, 2)
        %     % current time step
        %     smb_tmp = smb_data(:, i);

        %     % pick smb values per element, and average vertices to one value per element
        %     delta_smb_elements = smb_tmp(md.mesh.elements) * [1; 1; 1] / 3;

        %     smb_anomaly(i) = sum(delta_smb_elements .* mesh_areas);
        % end
        smb_anomaly =  md.smb.mass_balance(1:end-1, :) - md.miscellaneous.dummy.ref_smb_racmo;

        smb_anomaly = integrate_field_spatially(md, smb_anomaly)'; % convert to m/yr IE (mesh area is in meters)
        % smb_box_anomaly = ref_smb_box - smb_box_lia;
        figure(2);
        plot(linspace(start_time, final_time, length(smb_anomaly)), smb_anomaly, '-r');
        title('SMB anomaly 1900-2022')
        ylabel('SMB anomaly [mIE/yr]')
        xlim([1897, 2023])
        saveas(gcf, fullfile(save_path, 'smb_anomaly_1900-2022.png'))

        plotmodel(md, 'data', md.miscellaneous.dummy.ref_smb_box, 'figure', 3, 'title', 'Ref. BOX SMB Avg. (1960-1990)');
        plotmodel(md, 'data', md.miscellaneous.dummy.ref_smb_racmo, 'figure', 4, 'title', 'Ref. RACMO SMB Avg. (1960-1990)');
        saveas(gcf, 'smb_racmo_ref.png')


        I_smb = integrate_field_spatially(md, md.smb.mass_balance(1:end-1, :)) * md.materials.rho_ice * 1e-12; % from m^3/yr to Gt/yr
        I_cumulative_smb = dt * cumtrapz(I_smb); % * with 1/12 because doc of cumtrapz says that it is equivalent to inputting the distance between data points.
        I_cumulative_smb_anom = dt * cumtrapz(smb_anomaly');


        % figure(6);
        % plot(linspace(start_time, final_time, length(I_cumulative_smb)), I_cumulative_smb, '-r');
        % title('SMB, Cumulative sum')
        % % ylabel('SMB [m^3/yr (IE)]')
        % ylabel('SMB [Gt/yr]')
        % xlim([1897, 2023])
        % saveas(gcf, fullfile(save_path, 'smb_cumulative.png'))

        % figure(61);
        % plot(linspace(start_time, final_time, length(I_cumulative_smb_anom)), I_cumulative_smb_anom, '-r');
        % title('SMB anomaly, cumulated')
        % % ylabel('SMB [m^3/yr (IE)]')
        % ylabel('SMB [Gt/yr]')
        % xlim([1897, 2023])
        % saveas(gcf, fullfile(save_path, 'smb_anomaly_cumulative.png'))

        smb_times = linspace(start_time, final_time, length(I_smb));
        dt = mean(diff(smb_times)); % = 1/12
        vol_interp = interp1(vol_times, vol, smb_times, 'linear', 'extrap');
        disp(mean(vol_interp))
        vol_diff = diff(vol_interp) ./ dt;
        disp(mean(vol_diff))
        vol_diff = vol_diff * md.materials.rho_ice * 1e-12; % density of ice in Gt/km^3

        figure(7);
        subplot(2, 1, 1);
        plot(smb_times, I_smb, '-r');
        title('SMB, Integrated spatially')
        % ylabel('SMB [m^3/yr (IE)]')
        ylabel('SMB [Gt/yr]')
        xlim([1897, 2023])

        subplot(2, 1, 2);
        plot(smb_times(2:end), vol_diff, '-r');
        title('Ice volume derivative')
        % ylabel('Volume change [km^3/yr]')
        ylabel('Volume change [Gt/yr]')
        xlim([1897, 2023])
        saveas(gcf, fullfile(save_path, 'smb_vs_vol.png'))

        I_mov_avg = movmean(I_smb, 120);
        vol_diff_mov_avg = movmean(vol_diff, 120);
        smb_anom_mov_avg = movmean(smb_anomaly, 120);
        time_10_yrs = linspace(1900, 2022, length(I_mov_avg));

        
        figure(71);
        subplot(3, 1, 1);
        plot(time_10_yrs, I_mov_avg, '-r');
        title('SMB, Integrated spatially')
        % ylabel('SMB [mIE/yr]')
        ylabel('SMB [Gt/yr]')
        xlim([1897, 2023])

        subplot(3, 1, 2);
        plot(time_10_yrs(2:end), vol_diff_mov_avg, '-r');
        title('Ice volume derivative')
        % ylabel('Volume change [km^3/yr]')
        ylabel('Volume change [Gt/yr]')
        xlim([1897, 2023])

        subplot(3, 1, 3);
        plot(time_10_yrs, dt * cumtrapz(smb_anom_mov_avg), '-r');
        title('Accumulated SMB anomaly, 10yr mov. avg.')
        % ylabel('SMB [mIE/yr]')
        ylabel('SMB [Gt/yr]')
        xlim([1897, 2023])
        saveas(gcf, fullfile(save_path, 'smb_vs_vol_10yr_movavg.png'))
    end;

% subplot(2, 1, 2);
% plot(linspace(start_time, final_time, length(I_10yr_avg)), I_10yr_avg, '-r');
% title('SMB, Integrated spatially, 10 year avg')
% ylabel('SMB [mIE/yr]')
% xlim([1897, 2023])

% movie_log_vel(md, 'log_vel_racmo_recon');
% movie_log_vel(md, 'log_vel_racmo_recon');

if find(strcmp(plot_options, 'thickness'))
    %% Thickness
    % find 2007 average thickness
    times = [md.results.TransientSolution.time];
    pos = find(times > 2007 & times < 2008);
    model_avg_thickness = mean([md.results.TransientSolution(pos).Thickness], 2);

    % bedmachine thickness
    bed  = interpBmGreenland(md.mesh.x,md.mesh.y,'bed');
    surface = interpBmGreenland(md.mesh.x,md.mesh.y,'surface');

    thickness_2007 = surface - bed;

    % remove ice-free areas:
    ice_levelset_end_of_year = md.results.TransientSolution(pos(end)).MaskIceLevelset;
    ice_free_pos = ice_levelset_end_of_year > 0;

    model_avg_thickness(ice_free_pos) = 0;
    bm_thickness(ice_free_pos) = 0;
    residual_thickness = model_avg_thickness - thickness_2007;
    rmse = sqrt(mean((residual_thickness).^2));
    fileID = fopen(fullfile(save_path, 'rmse_thickness.txt'),'w');
    fprintf(fileID, "RMSE Thickness in 2007 is %f \n", rmse);

    plotmodel(md, 'data', residual_thickness, 'figure', 9, 'title', 'Thickness Misfit (2007 avg)', 'caxis', [-400, 400]);
    saveas(gcf, fullfile(save_path, 'residual_thickness.png'))

    times = [md.results.TransientSolution.time];
    index_2021 = find(times > 2020 & times < 2022);

    % load observed thickness in 2021 from Ice Sat 2
    obs_surface = interp2021Surface(md, [md.mesh.x, md.mesh.y]);                             
    obs_thickness = obs_surface - md.geometry.base;
    pred_thickness = mean([md.results.TransientSolution(index_2021).Thickness], 2, 'omitnan');

    % compute misfit and MAE
    misfit_thickness = pred_thickness - obs_thickness; 

    % base mae computation on relevant areas
    % misfit_thickness(misfit_thickness<-error_cap) = -error_cap;
    % misfit_thickness(misfit_thickness>=error_cap) = error_cap;
    
     % remove ice-free areas:
    ice_levelset_end_of_year = md.results.TransientSolution(pos(end)).MaskIceLevelset;
    ice_free_pos = ice_levelset_end_of_year > 0;
    misfit_thickness(ice_free_pos) = NaN; % ocean / irrelavant front area, cannot be updated
    % misfit_thickness(mask == 1) = NaN; % non-ice areas

    % compute mean abs error
    mae_thickness = mean(abs(misfit_thickness), 'omitnan');

    % remove NaNs, insert 0 misfit
    misfit_thickness(isnan(misfit_thickness)) = 0;

end
% %% Thickness wrt topo
%  bed = md.geometry.bed;
%  ice_surface = md.geometry.surface
%  pos = bed >= ice_surface;
 

%% Velocity best fit
% select a specfic date
% for year = 2004:2019
%     pos = find(times > year & times < year+1);
%     % fprintf("Velocity at %s\n", datestr(decyear2date(times(pos(14)))))
%     model_velocity = mean([md.results.TransientSolution(pos).Vel], 2);
%     interpolated_velocity = md.inversion.vel_obs;

%     % remove ice_free areas
%     ice_levelset_end_of_year = md.mask.ice_levelset;
%     ice_free_pos = ice_levelset_end_of_year > 0;

%     model_velocity(ice_free_pos) = 0;
%     interpolated_velocity(ice_free_pos) = 0;

%     residual_velocity = model_velocity - interpolated_velocity;
%     rmse(year-2004+1) = sqrt(mean((residual_velocity).^2));
% end

% [val, ind] = min(rmse);
% selected_year = ind+2004-1;
% pos = find(times > selected_year & times < selected_year+1);
% % date_ind = 14;
% % fprintf("Velocity at %s\n", datestr(decyear2date(times(pos(14)))))
% model_velocity = mean([md.results.TransientSolution(pos).Vel], 2);
% interpolated_velocity = md.inversion.vel_obs;

% % remove ice_free areas
% % remove ice-free areas:
% ice_levelset_end_of_year = md.mask.ice_levelset;
% ice_free_pos = ice_levelset_end_of_year > 0;

% model_velocity(ice_free_pos) = 0;
% interpolated_velocity(ice_free_pos) = 0;


% residual_velocity = model_velocity - interpolated_velocity;
% rmse = sqrt(mean((residual_velocity).^2));

% fprintf("RMSE Velocity on %d is %f \n", selected_year, rmse)
% plotmodel(md, 'data', residual_velocity, 'figure', 2, 'title', 'Min Vel Misfit (2019 avg)');

% %% Velocity 2007
% selected_year = 2007;
% pos = find(times > selected_year & times < selected_year+1);
% % date_ind = 14;
% % fprintf("Velocity at %s\n", datestr(decyear2date(times(pos(14)))))
% model_velocity = mean([md.results.TransientSolution(pos).Vel], 2);
% interpolated_velocity = md.inversion.vel_obs;

% % remove ice_free areas
% % remove ice-free areas:
% ice_levelset_end_of_year = md.mask.ice_levelset;
% ice_free_pos = ice_levelset_end_of_year > 0;

% model_velocity(ice_free_pos) = 0;
% interpolated_velocity(ice_free_pos) = 0;

% residual_velocity = model_velocity - interpolated_velocity;
% rmse = sqrt(mean((residual_velocity).^2));

% fprintf("RMSE Velocity on %d is %f \n", selected_year, rmse)
% plotmodel(md, 'data', residual_velocity, 'figure', 3, 'title', 'Vel Misfit (2007 avg)');

% %% Observed velocity
% data_vx = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vx_v1.tif';
% data_vy = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vy_v1.tif';
% [observed_vel, ~, ~] = interpVelocity(md, data_vx, data_vy);
% plotmodel(md, 'data', observed_vel, 'figure', 4, 'title', 'Observations (1995-2017)', 'log', 10, 'caxis', [1 1.2e4]);


% %% Volume plot
% figure(5);
% subplot(2, 1, 1);
% plot(cell2mat({md.results.TransientSolution(:).time}), cell2mat({md.results.TransientSolution(:).IceVolume}) / (1e9), '-r');
% title('Ice Volume [km^3]')

% times = [md.results.TransientSolution.time];
% % pos = find(times > 2007);
% subplot(2, 1, 2);
% plot(cell2mat({md.results.TransientSolution(:).time}), cell2mat({md.results.TransientSolution(:).IceVolume}) / (1e9), '-r');
% xlim([2007, 2020])
% plot(cell2mat({md.results.TransientSolution(pos).time}), cell2mat({md.results.TransientSolution(pos).IceVolume}) / (1e9), '-r');

%% spc plots
% plotmodel(md, 'data', md.masstransport.spcthickness(1:end-1, 1)  , 'figure', 8, 'title', 'spc thickness 1900', 'nan', -100);
% plotmodel(md, 'data', md.masstransport.spcthickness(1:end-1, 2)  , 'figure', 9, 'title', 'spc thickness 2007', 'nan', -100);
% spcvel = sqrt(md.stressbalance.spcvx.^2 + md.stressbalance.spcvy.^2);
% plotmodel(md, 'data', spcvel, 'figure', 10, 'title', 'spc vel (log)', 'log', 10, 'caxis', [1 1.2e4], 'nan', -100);

% figure(6);
% subplot(2, 1, 1);
% plot(cell2mat({md.results.TransientSolution(:).time}),(cell2mat({md.results.TransientSolution(:).IceVolumeAboveFloatation}) - md.results.TransientSolution(1).IceVolumeAboveFloatation)/1e9,'-r');
% title('Ice Volume Above Floatation, wrt to initial [km^3]')

% times = [md.results.TransientSolution.time];
% pos = find(times > 2007);
% subplot(2, 1, 2);
% plot(cell2mat({md.results.TransientSolution(pos).time}),(cell2mat({md.results.TransientSolution(pos).IceVolumeAboveFloatation}) - md.results.TransientSolution(1).IceVolumeAboveFloatation)/1e9, '-r');


% expcontourlevelzero(md, md.mask.ice_levelset, 0, 'temp.exp')
% plotmodel(md, 'data', 'driving_stress', 'caxis', [0, 200], 'expdisp', 'temp.exp', 'figure', 7)
