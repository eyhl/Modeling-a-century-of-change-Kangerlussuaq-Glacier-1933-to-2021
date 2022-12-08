function [] = compare_initial_states(md, md_list, md_names)
    [stats0, vel0] = velocity_statistics(md);
    lia_difference = {};
    figure(29)
    histogram(log(1 + vel0) / log(10));
    title('Log distributions of Velocity')
    hold on
    if length(md_list)>=1
        for i=1:length(md_list)
            [stats, vel] = velocity_statistics(md_list(i));
            histogram(log(1 + vel)/log(10));
            lia_difference{i} = sprintf('%s, mu/mu0=%.2f, nu/nu0=%.2f', md_names{i}, stats.log_dist.mu / stats0.log_dist.mu, stats.log_dist.nu / stats0.log_dist.nu);
        end
    end
    legend(['Reference', lia_difference])
end