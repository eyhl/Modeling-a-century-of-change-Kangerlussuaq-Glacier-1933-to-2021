function [smb_racmo_reconstructed, smb_total, smb_times] = reconstruct_racmo(md, start_time, final_time, ref_start_time, ref_end_time)
    ref_time_length = ref_end_time - ref_start_time;
    smb_total = md.smb.mass_balance(1:end - 1, :);

    % reference racmo smb
    md_racmo = md;
    racmo_file_name = 'Data/smb/racmo/';
    the_files = dir(fullfile(racmo_file_name, '*.nc'));
    md_racmo = interpolate_racmo_smb(md_racmo, ref_start_time, ref_end_time, the_files);
    time_vector = md_racmo.smb.mass_balance(end, :) - ref_start_time;
    smb_racmo_data = md_racmo.smb.mass_balance(1:end - 1, :);
    ref_smb_racmo = trapz(time_vector, smb_racmo_data, 2) / ref_time_length;
    
    % % % fix zeros in ocean in racmo data:
    % [front_area_smb, front_area_pos] = extrapolate_smb(md_racmo);
    % ref_smb_racmo(front_area_pos) = front_area_smb;                                                            

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

    % % save diagnostic fields:
    md.miscellaneous.dummy.smb_anomaly = smb_box_anomaly;
    md.miscellaneous.dummy.ref_smb_racmo = ref_smb_racmo;
    md.miscellaneous.dummy.ref_smb_box = ref_smb_box;

    % Extrapolate into fjord using avg racmo ref at front and anomaly
    pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/ref_racmo_front.exp', 2));             
    avg_smb_at_front = mean(ref_smb_racmo(pos)); % average in front area of ref racmo                                                                   
    pos2 = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area_smb.exp', 2));
    extrapolated_smb = avg_smb_at_front - smb_box_anomaly(pos2, :);                                                     
    smb_racmo_reconstructed(pos2, :) = extrapolated_smb; 

    smb_total = cat(2, smb_racmo_reconstructed, smb_total);
    smb_times = [start_time + 1/24 : 1/12 : final_time + 1];

    % tmp1 = ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area.exp', 2);
    % tmp2 = smb_total == 0;
    % for i=1:size(smb_total, 2)
    %     pos = find(logical(tmp1) .* tmp2(:, i));
    %     smb_total(pos) = 

    % set transient forcings
    % fprintf("data dimension = %d, time dimension = %d\n", size(smb_total, 2), size(smb_times, 2));
    
    % md.smb.mass_balance = [smb_total; ...
    %                        smb_times];
end