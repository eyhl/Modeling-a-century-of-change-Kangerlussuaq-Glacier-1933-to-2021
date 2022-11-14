function [] = tmp_plotting(absolute, zoom, cval)

    if nargin < 1
        absolute = false
    end
    snap_shot = false; % only produce snapshot plots of specific models, otherwise movie.
    
    md1 = loadmodel('Models/accepted_models/Model_kangerlussuaq_budd.mat');
    md2 = loadmodel('Models/accepted_models/schoof_0.6_5000_2_i14.mat');
    md3 = loadmodel('Models/accepted_models/schoof_0.7_5000_2_i14.mat');
    md4 = loadmodel('Models/accepted_models/schoof_0.8_5000_2_i14.mat');
    % md5 = loadmodel('md_s5.mat');

    misfit1 = md1.results.StressbalanceSolution.Vel;% - md1.inversion.vel_obs;
    misfit2 = md2.results.StressbalanceSolution.Vel;% - md2.inversion.vel_obs;
    misfit3 = md3.results.StressbalanceSolution.Vel;% - md3.inversion.vel_obs;
    misfit4 = md4.results.StressbalanceSolution.Vel ;%- md4.inversion.vel_obs;
    % misfit5 = md5.results.StressbalanceSolution.Vel - md5.inversion.vel_obs;

    misfit1(md1.inversion.vel_obs==0) = 0;
    misfit2(md2.inversion.vel_obs==0) = 0;
    misfit3(md3.inversion.vel_obs==0) = 0;
    misfit4(md4.inversion.vel_obs==0) = 0;
    % misfit5(md5.inversion.vel_obs==0) = 0;

    if absolute
        misfit1 = abs(misfit1);
        misfit2 = abs(misfit2);
        misfit3 = abs(misfit3);
        misfit4 = abs(misfit4);
        % misfit5 = abs(misfit5);
    end

    % plotmodels
    if snap_shot
        if nargin < 2
            plotmodel(md1, 'data', misfit1, 'title', 'budd', 'data', misfit2, 'title', 'Cmax=0.6', 'data', misfit3, 'title', 'Cmax=0.7', 'data', misfit4, 'title', 'Cmax=0.8', 'figure', 120); colormap('turbo');
            plotmodel(md1, 'data', md1.results.StressbalanceSolution.Gradient1, 'title', 'budd', 'data',  md2.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.6', ...
            'data', md3.results.StressbalanceSolution.Gradient1,  'title', 'Cmax=0.7', 'data',  md4.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.8', 'figure', 121); colormap('turbo');
        elseif nargin < 3
            plotmodel(md1, 'data', misfit1, 'title', 'budd', 'data', misfit2, 'title', 'Cmax=0.6', 'data', misfit3, 'title', 'Cmax=0.7', 'data', misfit4, 'title', 'Cmax=0.8', 'axis#all', zoom, 'figure', 120); colormap('turbo');
            plotmodel(md1, 'data', md1.results.StressbalanceSolution.Gradient1, 'title', 'budd', 'data',  md2.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.6', ...
            'data',  md3.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.7',  'data',  md4.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.8', 'axis#all', zoom, 'figure', 121); colormap('turbo');

        else
            plotmodel(md1, 'data', misfit1, 'title', 'budd', 'data', misfit2, 'title', 'Cmax=0.6', 'data', misfit3, 'title', 'Cmax=0.7', 'data', misfit4, 'title', 'Cmax=0.8', 'axis#all', zoom, 'caxis#all', cval(1, :), 'figure', 120); colormap('turbo');
            plotmodel(md1, 'data', md1.results.StressbalanceSolution.Gradient1, 'title', 'budd', 'data',  md2.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.6', ...
            'data',  md3.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.7',  'data',  md4.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.8', 'axis#all', zoom, 'caxis#all', cval(2, :), 'figure', 121); colormap('turbo');
        end
    else
        for i=2:2
            disp(i-1)
            fprintf("md%d.mat\n", i);
            fprintf("md%d.mat\n", i + 25);
            fprintf("md%d.mat\n", i + 25 * 2);
            fprintf("md%d.mat\n", i + 25 * 3);
            fprintf("md%d.mat\n\n", i + 25 * 4);
            % md1 = loadmodel(sprintf("Models/schoof_grid_run/md%d.mat", i));
            % md2 = loadmodel(sprintf("Models/schoof_grid_run/md%d.mat", i + 25));
            % md3 = loadmodel(sprintf("Models/schoof_grid_run/md%d.mat", i + 25 * 2));
            % md4 = loadmodel(sprintf("Models/schoof_grid_run/md%d.mat", i + 25 * 3));
            % md5 = loadmodel(sprintf("Models/schoof_grid_run/md%d.mat", i + 25 * 4));

            md_budd = loadmodel('Models/accepted_models/Model_kangerlussuaq_budd.mat');
            md1 = loadmodel('Models/schoof_grid_run/md14.mat');
            md2 = loadmodel('Models/schoof_grid_run/md37.mat');
            md3 = loadmodel('Models/schoof_grid_run/md64.mat');
            md4 = loadmodel('Models/schoof_grid_run/md88.mat');
            md5 = loadmodel('Models/schoof_grid_run/md112.mat');

            misfit_budd = md_budd.results.StressbalanceSolution.Vel - md_budd.inversion.vel_obs;
            misfit1 = md1.results.StressbalanceSolution.Vel - md1.inversion.vel_obs;
            misfit2 = md2.results.StressbalanceSolution.Vel - md2.inversion.vel_obs;
            misfit3 = md3.results.StressbalanceSolution.Vel - md3.inversion.vel_obs;
            misfit4 = md4.results.StressbalanceSolution.Vel - md4.inversion.vel_obs;
            misfit5 = md5.results.StressbalanceSolution.Vel - md5.inversion.vel_obs;

            vel_budd = md_budd.results.StressbalanceSolution.Vel;
            vel1 = md1.results.StressbalanceSolution.Vel;
            vel2 = md2.results.StressbalanceSolution.Vel;
            vel3 = md3.results.StressbalanceSolution.Vel;
            vel4 = md4.results.StressbalanceSolution.Vel;
            vel5 = md5.results.StressbalanceSolution.Vel;

            misfit_budd(md_budd.inversion.vel_obs==0) = 0;
            misfit1(md1.inversion.vel_obs==0) = 0;
            misfit2(md2.inversion.vel_obs==0) = 0;
            misfit3(md3.inversion.vel_obs==0) = 0;
            misfit4(md4.inversion.vel_obs==0) = 0;
            misfit5(md5.inversion.vel_obs==0) = 0;

            % plotmodel(md1, 'data', vel1, 'title', 'Cmax=0.5', 'data', vel2, 'title', 'Cmax=0.6', 'data', vel3, 'title', 'Cmax=0.7', 'data', vel4,  'title', 'Cmax=0.8','data', vel5, 'title', 'Cmax=0.9', 'data', vel_budd, 'title', 'Budd', 'axis#all', ...
            % zoom, 'figure', 120); colormap('turbo'); exportgraphics(gcf, sprintf("vel%d.png", i - 1), 'Resolution', 400);

            % plotmodel(md1, 'data', misfit1, 'title', 'Cmax=0.5', 'data', misfit2, 'title', 'Cmax=0.6', 'data', misfit3, 'title', 'Cmax=0.7', 'data', misfit4, 'title', 'Cmax=0.8', 'data', misfit5, 'title', 'Cmax=0.9', 'data', misfit_budd, 'title', 'Budd', ...
            %  'axis#all', zoom, 'figure', 121); colormap('turbo'); exportgraphics(gcf, sprintf("misfit%d.png", i - 1), 'Resolution', 400);

            % plotmodel(md1, 'data', misfit1, 'title', 'Cmax=0.5', 'data', misfit2, 'title', 'Cmax=0.6', 'data', misfit3, 'title', 'Cmax=0.7', 'data', misfit4, 'title', 'Cmax=0.8', 'data', misfit5, 'title', 'Cmax=0.9', 'data', misfit_budd, 'title', 'Budd', ...
            %  'axis#all', zoom, 'caxis#all', cval(1, :), 'figure', 122); colormap('turbo'); exportgraphics(gcf, sprintf("misfit_cval%d.png", i - 1), 'Resolution', 400);

            % plotmodel(md1, 'data', md1.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.5', 'data',  md2.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.6', ...
            % 'data',  md3.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.7', 'data',  md4.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.8', ...
            % 'data',  md5.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.9', 'data', md_budd.results.StressbalanceSolution.Gradient1, 'title', 'Budd', 'axis#all', zoom, 'figure', 123); colormap('turbo'); exportgraphics(gcf, sprintf("gradient%d.png", i - 1), 'Resolution', 400);

            % plotmodel(md1, 'data', md1.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.5', 'data',  md2.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.6', ...
            % 'data',  md3.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.7', 'data',  md4.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.8', ...
            % 'data',  md5.results.StressbalanceSolution.Gradient1, 'title', 'Cmax=0.9', 'data', md_budd.results.StressbalanceSolution.Gradient1, 'title', 'Budd', 'axis#all', zoom, 'caxis#all', cval(2, :), 'figure', 124); colormap('turbo'); exportgraphics(gcf, sprintf("gradient_cval%d.png", i - 1), 'Resolution', 400);

            plotmodel(md1, 'data', md1.friction.C, 'title', 'Cmax=0.5', 'data',  md2.friction.C, 'title', 'Cmax=0.6', ...
            'data',  md3.friction.C, 'title', 'Cmax=0.7', 'data',  md4.friction.C, 'title', 'Cmax=0.8', ...
            'data',  md5.friction.C, 'title', 'Cmax=0.9', 'data', md_budd.friction.coefficient, 'title', 'Budd', 'axis#all', zoom, 'log#all', 10, 'caxis#all', [0.01 1e4], 'figure', 125); colormap('turbo'); exportgraphics(gcf, sprintf("friction_C%d.png", i - 1), 'Resolution', 400);

            % misfit1 = abs(misfit1);
            % misfit2 = abs(misfit2);
            % misfit3 = abs(misfit3);
            % misfit4 = abs(misfit4);
            % misfit5 = abs(misfit5);
            % plotmodel(md1, 'data', misfit1, 'data', misfit2, 'data', misfit3, 'data', misfit4, 'data', misfit5, 'axis#all', zoom, 'caxis#all', cval(1, :), 'figure', 120); exportgraphics(gcf, sprintf("abs_misfit%d.png", i - 1), 'Resolution', 400);
        end

    end
    % md1.inversion.cost_functions_coefficients(1, 3)
    % md2.inversion.cost_functions_coefficients(1, 3)
    % md3.inversion.cost_functions_coefficients(1, 3)
    % md4.inversion.cost_functions_coefficients(1, 3)
    % md5.inversion.cost_functions_coefficients(1, 3)

    % plotmodel(md1, 'data', md1.inversion.cost_functions_coefficients(:, 3), 'data', md2.inversion.cost_functions_coefficients(:, 3), 'data', md3.inversion.cost_functions_coefficients(:, 3), ...
    % 'data', md4.inversion.cost_functions_coefficients(:, 3), 'data', md5.inversion.cost_functions_coefficients(:, 3), 'axis#all', zoom, 'figure', 122)

end
