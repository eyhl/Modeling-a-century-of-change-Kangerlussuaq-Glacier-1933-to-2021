function [stats, vel] = velocity_statistics(md)
    % mean(mdb.results.StressbalanceSolution.Vel) = 715.5533
    % std(mdb.results.StressbalanceSolution.Vel) = 1.5335e+03
    % max(mdb.results.StressbalanceSolution.Vel) = 6.9819e+03
    % mean(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 2.0830
    % std(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 0.8722
    % max(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 3.8440
    stats = {};
    stats.dist = {};
    stats.log_dist = {};

    fast_flow_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, 'Exp/fast_flowing_region.exp', 2));
    vel = md.results.StressbalanceSolution.Vel(fast_flow_pos);
    vel(vel == 0) = NaN;
    vel(vel >= 1e4) = [];
    vel(vel <= 0.01) = [];


    % Normal
    stats.dist.mu = mean(vel, 'omitnan');
    stats.dist.nu = median(vel, 'omitnan');
    stats.dist.sigma = std(vel, 'omitnan');
    stats.dist.maxv = max(vel);

    % Log distribution
    stats.log_dist.mu = mean(log(1 + vel)/log(10), 'omitnan');
    stats.log_dist.nu = median(log(1 + vel)/log(10), 'omitnan');
    stats.log_dist.sigma = std(log(1 + vel)/log(10), 'omitnan');
    stats.log_dist.maxv = max(log(1 + vel)/log(10));
end