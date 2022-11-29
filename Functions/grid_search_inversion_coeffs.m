function [mae_list] = grid_search_inversion_coeffs(friction_law)
    if strcmp(friction_law, 'budd')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_param.mat');
        cs_min = 0.01;
        cs_max = 1e4;
        c_max_list = [NaN]; % array with length 1, budd does not have cmax
        coefficient_1 = [16000];  %try 350, 1, 1e-12
        coefficient_2 = [3.0]; % linspace(0.5, 5, 6);
        coefficient_3 = [1e-9, logspace(-7, -1, 25), 1e1]; % 1.0608e-06
    elseif strcmp(friction_law, 'schoof')
        md = loadmodel('Models/accepted_models/Model_kangerlussuaq_budd.mat');
        cs_min = 0.01;
        cs_max = 1e4;
        c_max_list = [0.66, 0.74, 0.77, 0.81, 0.84, 0.90]; %linspace(0.2, 1.0, 15);
        coefficient_1 = [2500]; %måske ned
        coefficient_2 = [1250, 600, linspace(350, 200, 4), 20, 10, 5, 2.0]; % måske op linspace(1, 7, 6);
        % coefficient_3 = [logspace(-11, -9, 3), 5e-9, linspace(1e-8, 1e-7, 10), 2e-7, 3e-7, 4e-7, 5e-7,logspace(-6, -1, 6)]; %logspace(-15, -1, 40); 
        coefficient_3 = linspace(1e-8, 1e-7, 15);
    else
        warning("Friction law not implemented")
    end

    % save iterators
    save('c_max_list.mat', 'c_max_list');
    save('coefficient_1.mat', 'coefficient_1');
    save('coefficient_2.mat', 'coefficient_2');
    save('coefficient_3.mat', 'coefficient_3');

    cluster = generic('name', oshostname(), 'np', 33);
    md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
    md.cluster = cluster;

    total_iterations = length(c_max_list) * length(coefficient_1) * length(coefficient_2) * length(coefficient_3);
    mae_list = zeros(total_iterations, 1);
    coef_setting = zeros(total_iterations, 4);
    counter = 1;
    fid = fopen(['coef_settings_', friction_law, '.txt'],'w');

    % load budd model LIA
    md_budd_lia = loadmodel('Models/kg_budd_lia.mat');

    tStart = tic;
    for i=1:length(c_max_list)
        for j=1:length(coefficient_2)
            for k=1:length(coefficient_3)
                fprintf("Iteration %d/%d\n", counter, total_iterations)
                coefs = [coefficient_1(1), coefficient_2(j), coefficient_3(k), c_max_list(i)];
                fprintf("Current coefficient setting: %s\n", num2str(coefs))


                if strcmp(friction_law, 'schoof')
                    [md_tmp] = budd2schoof(md, coefs, cs_min, cs_max);
                    friction_field = md_tmp.friction.C;
                elseif strcmp(friction_law, 'budd')
                    md_tmp = solve_stressbalance_budd(md,  coefs, cs_min, cs_max);
                    friction_field = md_tmp.friction.coefficient;
                else
                    warning("Friction law not implemented")
                end

                % Measure LIA misfit wrt to Budd solution
                md_schoof_lia = parameterize(md_tmp, 'ParameterFiles/transient_lia.par');
                [extrapolated_friction, extrapolated_pos, ~] = friction_correlation_model(md_schoof_lia, cs_min, 6, 'schoof', false); 
                extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
                md_schoof_lia.friction.C(extrapolated_pos) = extrapolated_friction;
                md_schoof_lia.inversion.iscontrol = 0;
                md_schoof_lia = solve(md_schoof_lia, 'sb');

                LIA_misfit = 0.5 .* ((md_schoof_lia.results.StressbalanceSolution.Vx - md_budd_lia.results.StressbalanceSolution.Vx).^2 + ...
                                     (md_schoof_lia.results.StressbalanceSolution.Vy - md_budd_lia.results.StressbalanceSolution.Vy).^2);
                LIA_misfit(md_schoof_lia.mask.ice_levelset>0) = 0;
                [LIA_misfit] = integrate_field_spatially(md_schoof_lia, LIA_misfit);

                LIA_log_misfit = ((md_schoof_lia.results.StressbalanceSolution.Vel + 1e-8 ./ md_budd_lia.results.StressbalanceSolution.Vel + 1e-8)).^2;
                LIA_log_misfit(md_schoof_lia.mask.ice_levelset>0) = log(1e-8);
                if sum(LIA_log_misfit == Inf) ~= 0
                    LIA_log_misfit(LIA_log_misfit == Inf) = log(1e-8);

                    % If there is more than 10% Inf ignore misfit
                    if sum(LIA_log_misfit == Inf) / length(LIA_log_misfit) > 0.1
                        LIA_log_misfit = Inf;
                    end
                end
                [LIA_log_misfit] = integrate_field_spatially(md_schoof_lia, LIA_log_misfit);

                mae_list(counter) = md_tmp.results.StressbalanceSolution.J(end, end); %mean(abs(misfit_velocity), 'omitnan');

                fprintf("LIA J0: %.10f\n", LIA_misfit + LIA_log_misfit)
                % vel_tmp = md_tmp.results.StressbalanceSolution.Vel;
                % plotmodel(md_tmp, 'data', vel_tmp, 'figure', 43, 'title', 'Vel', 'levelset', md_tmp.mask.ice_levelset, 'gridded', 1); exportgraphics(gcf, sprintf("vel_%d%d%d.png", i, j, k - 1), 'Resolution', 200);
                % plotmodel(md_tmp, 'data', friction_field, 'figure', 44, 'title', 'fc', 'levelset', md_tmp.mask.ice_levelset, 'gridded', 1); exportgraphics(gcf, sprintf("fc_%d%d%d.png", i, j, k - 1), 'Resolution', 200);
                % save(sprintf("vel_%d%d%d.mat", i, j, k - 1), 'vel_tmp', '-v7.3');
                % save(sprintf("fc_%d%d%d.mat", i, j, k - 1), 'friction_field', '-v7.3');
                % save setup
                fprintf(fid, '%s %.2f %.2f %.2f %.6g %.6f %.6f %s\n', datetime, coefs(4), coefs(1), coefs(2), coefs(3), ...
                                                                      LIA_misfit, LIA_log_misfit, num2str(md_tmp.results.StressbalanceSolution.J(end, :)));
                
                coef_setting(counter, :) = coefs;

                save(sprintf('md%d_%.2f_%d_%d_%.2g.mat', counter, coefs(4), coefs(1), coefs(2), coefs(3)), 'md_schoof_lia');
                counter = counter + 1;
        end
    end
end
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));

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









