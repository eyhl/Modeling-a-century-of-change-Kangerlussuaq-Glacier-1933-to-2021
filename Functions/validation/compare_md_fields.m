function [] = compare_md_fields(md1, md2)

    % integrate smbs (area weighted average) and compare
    I1 = integrate_smb(md1);
    I2 = integrate_smb(md2);
    if length(I1) > length(I2)
        pos = find(md1.smb.mass_balance(end, :) >= md2.smb.mass_balance(end, 1));
        time_index = pos(1);
        timeline = md1.smb.mass_balance(end, :);
        fprintf("Difference in integrated smbs = %f\n", sum(abs(I1(time_index:end) - I2)));
    elseif length(I1) < length(I2)
        pos = find(md2.smb.mass_balance(end, :) >= md1.smb.mass_balance(end, 1));
        time_index = pos(1);
        timeline = md2.smb.mass_balance(end, :);
        fprintf("Difference in integrated smbs = %f\n", sum(abs(I1 - I2(time_index:end))));
    end

    figure(5);
    title("Ice volume change")
    plot(cell2mat({md1.results.TransientSolution(:).time}), cell2mat({md1.results.TransientSolution(:).IceVolume}) / (1e9), 'b');
    hold on
    plot(cell2mat({md2.results.TransientSolution(:).time}), cell2mat({md2.results.TransientSolution(:).IceVolume}) / (1e9), '--r');
    legend('Reconstructed', 'RACMO'); % TODO: change label to md.miscellaneous.name
    ylabel('Ice Volume [km^3]')

end