function [md] = reconstruct_mar(md, start_time, final_time, ref_start_time, ref_end_time, the_files)
    ref_time_length = ref_end_time - ref_start_time;
    smb_total = md.smb.mass_balance(1:end - 1, :);

    % reference mar smb
    md_mar = md;
    md_mar = interpolate_mar_smb(md_mar, ref_start_time, ref_end_time, the_files);
    time_vector = md_mar.smb.mass_balance(end, :) - ref_start_time;
    smb_mar_data = md_mar.smb.mass_balance(1:end - 1, :);
    ref_smb_mar = trapz(time_vector, smb_mar_data, 2) / ref_time_length;
    
    % % % fix zeros in ocean in mar data:
    % [front_area_smb, front_area_pos] = extrapolate_smb(md_mar);
    % ref_smb_mar(front_area_pos) = front_area_smb;                                                            

    % reference box smb
    md_box = md;
    box_file_name = 'Data/smb/box_smb/Box_Greenland_SMB_monthly_1840-2012_5km_cal_ver20141007.nc';
    md_box = interpolate_box_smb(md_box, ref_start_time, ref_end_time, box_file_name);
    time_vector = md_box.smb.mass_balance(end, :) - ref_start_time;
    smb_box_data = md_box.smb.mass_balance(1:end - 1, :);
    ref_smb_box = trapz(time_vector, smb_box_data, 2) / ref_time_length;

    % box smb before mar starts
    md_lia = md;
    box_file_name = 'Data/smb/box_smb/Box_Greenland_SMB_monthly_1840-2012_5km_cal_ver20141007.nc';
    md_lia = interpolate_box_smb(md_lia, start_time, 1949, box_file_name);
    smb_box_lia = md_lia.smb.mass_balance(1:end - 1, :);

    % reconstruction
    smb_box_anomaly = ref_smb_box - smb_box_lia;
    smb_mar_reconstructed = ref_smb_mar - smb_box_anomaly;
    smb_mar_times = md_lia.smb.mass_balance(end, :);

    % % save diagnostic fields:
    md.miscellaneous.dummy.smb_anomaly = smb_box_anomaly;
    md.miscellaneous.dummy.ref_smb_mar = ref_smb_mar;
    md.miscellaneous.dummy.ref_smb_box = ref_smb_box;

    smb_total = cat(2, smb_mar_reconstructed, smb_total);
    smb_times = [start_time + 1/24 : 1/12 : final_time + 1]; % +1 makes the final time be 2022.0
    md.smb.mass_balance = [smb_total; ...
                           smb_times];
end