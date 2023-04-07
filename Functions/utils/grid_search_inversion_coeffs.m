function [mae_list] = grid_search_inversion_coeffs(friction_law)
    if strcmp(friction_law, 'budd')
        md = loadmodel('/data/eigil/work/lia_kq/Models/KG_param.mat');
        cs_min = 0.01;
        cs_max = 1e4;
        coefficient_0 = [NaN]; % array with length 1, budd does not have cmax
        coefficient_1 = [8000];  %try 350, 1, 1e-12
        coefficient_2 = [3.0]; % linspace(0.5, 5, 6);
        coefficient_3 = [1e-9, logspace(-7, -1, 25), 1e1]; % 1.0608e-06
    elseif strcmp(friction_law, 'schoof')
        md = loadmodel('/data/eigil/work/lia_kq/Models/KG_budd.mat');
        cs_min = 0.01;
        cs_max = 1e4;
        coefficient_0 = [0.66, 0.74, 0.77, 0.81, 0.84, 0.90]; %linspace(0.2, 1.0, 15);
        coefficient_1 = [2500]; %måske ned
        coefficient_2 = [1250, 600, linspace(350, 200, 4), 20, 10, 5, 2.0]; % måske op linspace(1, 7, 6);
        % coefficient_3 = [logspace(-11, -9, 3), 5e-9, linspace(1e-8, 1e-7, 10), 2e-7, 3e-7, 4e-7, 5e-7,logspace(-6, -1, 6)]; %logspace(-15, -1, 40); 
        coefficient_3 = linspace(1e-12, 1e-1, 10);
    elseif strcmp(friction_law, 'regcoulomb')
        md = loadmodel('/data/eigil/work/lia_kq/Models/KG_budd.mat');
        cs_min = 1e4;
        cs_max = 8e4;
        coefficient_0 = [580, 590, 600, 610, 1350, 1200, 1250]; %
        coefficient_1 = [300]; %måske ned
        coefficient_2 = logspace(-5, -3, 5); % måske op linspace(1, 7, 6);
        % coefficient_3 = [logspace(-11, -9, 3), 5e-9, linspace(1e-8, 1e-7, 10), 2e-7, 3e-7, 4e-7, 5e-7,logspace(-6, -1, 6)]; %logspace(-15, -1, 40); 
        coefficient_3 = logspace(-9, -8, 5);
    else
        warning("Friction law not implemented")
    end

    % save iterators
    save('coefficient_0.mat', 'coefficient_0');
    save('coefficient_1.mat', 'coefficient_1');
    save('coefficient_2.mat', 'coefficient_2');
    save('coefficient_3.mat', 'coefficient_3');

    cluster = generic('name', oshostname(), 'np', 30);
    md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
    md.cluster = cluster;

    total_iterations = length(coefficient_0) * length(coefficient_1) * length(coefficient_2) * length(coefficient_3);
    mae_list = zeros(total_iterations, 1);
    coef_setting = zeros(total_iterations, 4);
    counter = 1;
    fid = fopen(['coef_settings_', friction_law, '.txt'],'w');

    % load budd model LIA
    md_budd_lia = loadmodel('Models/KG_budd_lia.mat');

    tStart = tic;
    for i=1:length(coefficient_0)
        for m=1:length(coefficient_1)
            for j=1:length(coefficient_2)
                for k=1:length(coefficient_3)
                    fprintf("Iteration %d/%d\n", counter, total_iterations)
                    coefs = [coefficient_1(m), coefficient_2(j), coefficient_3(k), coefficient_0(i)];
                    fprintf("Current coefficient setting: %s\n", num2str(coefs))


                    if strcmp(friction_law, 'schoof')
                        [md_tmp] = budd2schoof(md, coefs, cs_min, cs_max);
                        % friction_field = md_tmp.friction.C;
                    elseif strcmp(friction_law, 'budd')
                        md_tmp = solve_stressbalance_budd(md,  coefs, cs_min, cs_max);
                        % friction_field = md_tmp.friction.coefficient;
                    elseif strcmp(friction_law, 'regcoulomb')
                        md_tmp = solve_stressbalance_regcoulomb(md, coefs, cs_min, cs_max);
                        % friction_field = md_tmp.friction.coefficient;
                    else
                        warning("Friction law not implemented")
                    end
                    plotmodel(md_tmp, 'data', md_tmp.friction.C, 'data', md_tmp.results.StressbalanceSolution.Vel, 'caxis#2', [0, 10e3], 'figure', 982)
                    exportgraphics(gcf, sprintf('GRID_REG_COULOMB/figures1/md%d_%.2f_%d_%d_%.2g.png', counter, coefs(4), coefs(1), coefs(2), coefs(3)), 'Resolution', 150);

                    % Measure LIA misfit wrt to Budd solution
                    md_main = parameterize(md_tmp, 'ParameterFiles/transient_lia.par');
                    % [extrapolated_friction, extrapolated_pos, ~] = friction_constant_model(md_main, cs_min, 'budd', false);
                    [extrapolated_friction, extrapolated_pos, ~] = friction_correlation_model(md_main, cs_min, 4, friction_law, false); 
                    extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
                    md_main.friction.C(extrapolated_pos) = extrapolated_friction;
                    md_main.inversion.iscontrol = 0;
                    md_main = solve(md_main, 'sb');

                    % LIA_misfit = 0.5 .* ((md_main.results.StressbalanceSolution.Vx - md_budd_lia.results.StressbalanceSolution.Vx).^2 + ...
                    %                      (md_main.results.StressbalanceSolution.Vy - md_budd_lia.results.StressbalanceSolution.Vy).^2);
                    masked_values = md.mask.ice_levelset<0;

                    LIA_misfit_vx = sqrt((md_main.results.StressbalanceSolution.Vx - md_budd_lia.results.StressbalanceSolution.Vx).^2);
                    LIA_misfit_vy = sqrt((md_main.results.StressbalanceSolution.Vy - md_budd_lia.results.StressbalanceSolution.Vy).^2);
                    LIA_misfit = 1 / 2 * (LIA_misfit_vx + LIA_misfit_vy);
                    LIA_misfit = integrateOverDomain(md_main, LIA_misfit, ~masked_values);

                    a = md_main.results.StressbalanceSolution.Vel;
                    b = md_budd_lia.results.StressbalanceSolution.Vel;
                    LIA_log_misfit = log_misfit(a, b, md.mask.ice_levelset>0);
                    LIA_log_misfit = integrateOverDomain(md_main, LIA_log_misfit, ~masked_values);

                    mae_list(counter) = md_tmp.results.StressbalanceSolution.J(end, end); %mean(abs(misfit_velocity), 'omitnan');

                    fprintf("LIA J0: %.5g\n", LIA_misfit + LIA_log_misfit)
                    fprintf(fid, '%s %.2f %.2f %.2f %.6g %.6f %.6f %s\n', datetime, coefs(4), coefs(1), coefs(2), coefs(3), ...
                                                                        LIA_misfit, LIA_log_misfit, num2str(md_tmp.results.StressbalanceSolution.J(end, :)));
                    
                    coef_setting(counter, :) = coefs;
                    plotmodel(md_main, 'data', md_main.friction.C, 'data', md_main.results.StressbalanceSolution.Vel, 'caxis#2', [0, 10e3], 'figure', 983)
                    exportgraphics(gcf, sprintf('GRID_REG_COULOMB/figures/md%d_%.2f_%d_%d_%.2g.png', counter, coefs(4), coefs(1), coefs(2), coefs(3)), 'Resolution', 150);
                    save(sprintf('GRID_REG_COULOMB/models/md%d_%.2f_%d_%d_%.2g.mat', counter, coefs(4), coefs(1), coefs(2), coefs(3)), 'md_main');
                    quantify_field_difference(md, md.initialization.vel, md.inversion.vel_obs, ...
                                              sprintf('GRID_REG_COULOMB/visual_sim/md%d_%.2f_%d_%d_%.2g', counter, coefs(4), coefs(1), coefs(2), coefs(3)), ...
                                              true, true, 1.0e+06 * [0.4533, 0.5123, -2.3140, -2.2425]);
                    counter = counter + 1;
                end
            end
        end
    end
    tEnd = toc(tStart);
    fprintf('%d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));
end
% SCHOOF SETTINGS
% with ratio of 10:5:1
% Var1          Var2          i      j      k          Var6            Term 1      Term 2      Term 3     Sum 
% ___________    ________    ____    ____    ____    _________________    ______    ______    ______    ______

% 06-Oct-2022    04:43:57     6       2       4      {'38.0:18.5:3.6'}    380.43    185.27    36.364    602.06

% with ratio 10:2:1
% Var1          Var2          i      j      k          Var6            Term 1      Term 2      Term 3     Sum 
% ___________    ________    ____    ____    ____    ________________    ______    ______    ______    ______

% 05-Oct-2022    20:59:51     2       2       2      {'40.7:7.8:4.1'}    407.31    77.563    41.316    526.19

% 101: SurfaceAbsVelMisfit
% 103: SurfaceLogVelMisfit
% 501: DragCoefficientAbsGradient









