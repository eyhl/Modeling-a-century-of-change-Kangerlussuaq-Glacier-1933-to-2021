function [mae_list] = grid_search_inversion_coeffs(friction_law)
    if strcmp(friction_law, 'schoof')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_budd.mat');
        c_max_list = linspace(0.3, 1.2, 4);
        coefficient_1 = 4000;
        coefficient_2 = [2.2, 5.8]; % linspace(1, 7, 6);
        coefficient_3 = logspace(-9, -3, 10);

    elseif strcmp(friction_law, 'budd')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_param.mat');
        c_max_list = [NaN]; % array with length 1, budd does not have cmax
        coefficient_1 = 4000;
        coefficient_2 = linspace(0.5, 5, 6);
        coefficient_3 = logspace(-9, -3, 10);

    else
        warning("Friction law not implemented")
    end
    cluster = generic('name', oshostname(), 'np', 66);
    md.cluster = cluster;

    total_iterations = length(c_max_list) * length(coefficient_1) * length(coefficient_2) * length(coefficient_3);
    mae_list = zeros(total_iterations, 1);
    coef_setting = zeros(total_iterations, 4);
    counter = 1;
    fid = fopen(['coef_settings', friction_law, '.txt'],'w');

    tStart = tic;
    for i=1:length(c_max_list)
        for j=1:length(coefficient_2)
            for k=1:length(coefficient_3)
                coefs = [coefficient_1, coefficient_2(j), coefficient_3(k), c_max_list(i)];
                fprintf("Current coefficient setting: %s\n", num2str(coefs))


                if strcmp(friction_law, 'schoof')
                    [md_tmp] = budd2schoof(md, coefs, 0.01, 1e4);
                    friction_field = md_tmp.friction.C;
                elseif strcmp(friction_law, 'budd')
                    md_tmp = solve_stressbalance_budd(md,  coefs, 0.01, 1e4);
                    friction_field = md.friction.coefficient;
                else
                    warning("Friction law not implemented")
                end

                
                mae_list(counter) = md_tmp.results.StressbalanceSolution.J(end, end); %mean(abs(misfit_velocity), 'omitnan');

                fprintf("Misfit level: %.10f\n", mae_list(counter))

                plotmodel(md_tmp, 'data', md_tmp.results.StressbalanceSolution.Vel, 'figure', 43, 'title', 'Vel'); exportgraphics(gcf, sprintf("vel_%d%d%d.png", i, j, k))
                plotmodel(md_tmp, 'data', friction_field, 'figure', 44, 'title', 'fc'); exportgraphics(gcf, sprintf("fc_%d%d%d.png", i, j, k))
                fprintf(fid, '%s %.2f %.2f %.2E %s\n', datetime, coefs(4), coefs(2), coefs(3), num2str(md_tmp.results.StressbalanceSolution.J(end, :)));

                coef_setting(counter, :) = coefs;
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
