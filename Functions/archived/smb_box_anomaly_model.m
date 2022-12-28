function [extrapolated_smb, extrapolated_pos] = smb_box_anomaly_model(md)
    %--
    % Extrapolates smb data based adding box anomaly to racmo average for every time step
    %--

    smb_anomaly = md.miscellaneous.dummy.smb_anomaly;
    ref_smb_racmo = md.miscellaneous.dummy.ref_smb_racmo;
    ref_smb_box = md.miscellaneous.dummy.ref_smb_box;

    average_ra

    %% --------------- TEMPORARY ---------------
    % reference box smb
    md_box = md;
    box_file_name = 'Data/smb/box_smb/Box_Greenland_SMB_monthly_1840-2012_5km_cal_ver20141007.nc';
    md_box = interpolate_box_smb(md_box, ref_start_time, ref_end_time, box_file_name);
    time_vector = md_box.smb.mass_balance(end, :) - ref_start_time;
    smb_box_data = md_box.smb.mass_balance(1:end - 1, :);
    ref_smb_box = trapz(time_vector, smb_box_data, 2) / ref_time_length;

    % box smb from lia to 1957
    md_lia = md;
    box_file_name = 'Data/smb/box_smb/Box_Greenland_SMB_monthly_1840-2012_5km_cal_ver20141007.nc';
    md_lia = interpolate_box_smb(md_lia, start_time, 1957, box_file_name);
    smb_box_lia = md_lia.smb.mass_balance(1:end - 1, :);

    % reconstruction
    smb_box_anomaly = ref_smb_box - smb_box_lia;
    smb_racmo_reconstructed = ref_smb_racmo - smb_box_anomaly;
    smb_racmo_times = md_lia.smb.mass_balance(end, :);

    % save diagnostic fields:
    md.miscellaneous.dummy.smb_anomaly = smb_box_anomaly;
    md.miscellaneous.dummy.ref_smb_racmo = ref_smb_racmo;
    md.miscellaneous.dummy.ref_smb_box = ref_smb_box;

end