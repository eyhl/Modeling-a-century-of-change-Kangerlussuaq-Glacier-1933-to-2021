function [] = run_batch_and_evaluate(axes, md_list)
    config_b = 'config-9dec-schoof-bed-corr.csv';
    config_cb = 'config-9dec-control-schoof-bed-corr.csv';
    config_s = 'config-9dec-schoof-const.csv';
    config_cs = 'config-9dec-weertman-bed_corr.csv';
    config_w = 'config-9dec-control-weertman-bed_corr.csv';
    config_cw = 'config-9dec-weertman-const.csv';
    if nargin < 2
        disp(' -------------------------- Computing models -------------------------- ')
        tic
        mdb = run_model(config_b, false);
        movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_budd.mat'); 
        mdcb = run_model(config_cb, false);
        movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_control_budd.mat'); 
        mds = run_model(config_s, false);
        movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_schoof.mat'); 
        mdcs = run_model(config_cs, false);
        movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_control_schoof.mat'); 
        mdw = run_model(config_w, false);
        movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_weertman.mat');
        mdcw = run_model(config_cw, false);
        movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_control_weertman.mat');
        toc
        % tic
        
        % copyfile('Models/Model_kangerlussuaq_friction_correction_schoof_bed_corr.mat', 'Models/Model_kangerlussuaq_friction_correction.mat'); 
        % mdb = run_model(config_b, false);
        % movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_schoof_bed_corr.mat'); 
        % mdcb = run_model(config_cb, false);
        % movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_control_schoof_bed_corr.mat'); 
        
        % copyfile('Models/Model_kangerlussuaq_friction_correction_schoof_constant.mat', 'Models/Model_kangerlussuaq_friction_correction.mat'); 
        % mds = run_model(config_s, false);
        % movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_schoof_const.mat'); 

        % copyfile('Models/Model_kangerlussuaq_friction_correction_weertman_bed_corr.mat', 'Models/Model_kangerlussuaq_friction_correction.mat'); 
        % mdcs = run_model(config_cs, false);
        % movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_weertman_bed_corr.mat'); 
        % mdw = run_model(config_w, false);
        % movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_control_weertman_bed_corr.mat');

        % copyfile('Models/Model_kangerlussuaq_friction_correction_weertman_constant.mat', 'Models/Model_kangerlussuaq_friction_correction.mat'); 
        % mdcw = run_model(config_cw, false);
        % movefile('Models/Model_kangerlussuaq_transient.mat', 'Models/Model_kangerlussuaq_transient_weertman_const.mat');

        % toc
    else
        if length(md_list)>1
            disp(length(md_list))
            mdb = md_list(1);                                                                                     
            mdcb =  md_list(2);                                                                                     
            mds = md_list(3);
            mdcs = md_list(4);
            mdw = md_list(5);
            mdcw = md_list(6);
        else
            disp(' -------------------------- Loading models -------------------------- ')
            mdb = loadmodel('Models/Model_kangerlussuaq_transient_budd.mat');                                                                                      
            mdcb = loadmodel('Models/Model_kangerlussuaq_transient_control_budd.mat');                                                                                      
            mds = loadmodel('Models/Model_kangerlussuaq_transient_schoof.mat');
            mdcs = loadmodel('Models/Model_kangerlussuaq_transient_control_schoof.mat');
            mdw = loadmodel('Models/Model_kangerlussuaq_transient_weertman.mat');
            mdcw = loadmodel('Models/Model_kangerlussuaq_transient_control_weertman.mat');        
        end
    end
    

    md_list = [mdb, mds, mdw];
    md_control_list = [mdcb, mdcs, mdcw];
    md_names = {'Budd', 'Budd control', 'Schoof', 'Schoof control', 'Weertman', 'Weertman control'};
    % md_names = {'Schoof (BedCorr)', 'Schoof control', 'Schoof (const)', 'Weertman  (BedCorr)', 'Weertman control', 'Weertman (const)'};

    md0 = loadmodel('Models/Model_kangerlussuaq_budd.mat');

    title1 = sprintf('Budd, MAE=%.1f', integrate_field_spatially(md0, abs(md0.geometry.thickness - mdb.results.TransientSolution(end).Thickness)) ./ (1e9));
    title2 = sprintf('Schoof, MAE=%.1f', integrate_field_spatially(md0, abs(md0.geometry.thickness - mds.results.TransientSolution(end).Thickness)) ./ (1e9));
    title3 = sprintf('Weertman, MAE=%.1f', integrate_field_spatially(md0, abs(md0.geometry.thickness - mdw.results.TransientSolution(end).Thickness)) ./ (1e9));

    compare_models(md_list, md_control_list, md_names, '.', md0.geometry.thickness)  

    plotmodel(md0, 'data', md0.geometry.thickness - mdb.results.TransientSolution(end).Thickness, ...
                'data', md0.geometry.thickness - mds.results.TransientSolution(end).Thickness, ...
                'data', md0.geometry.thickness - mdw.results.TransientSolution(end).Thickness, ...
                'caxis#all', [-2e2 2e2], 'mask#all', mdb.results.TransientSolution(end).MaskIceLevelset<0, ...
                'title#1', title1, 'title#2', title2, 'title#3', title3, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'colorbar#1-2', 'off', ...
                'axis#all', axes, 'figure', 89); colormap('turbo'); exportgraphics(gcf, fullfile('.', 'H_misfit.png'), 'Resolution', 300)

    
    fprintf('int(H_Schoof_tn - H_Budd_tn) = %.1f\n', integrate_field_spatially(mds, abs(mds.results.TransientSolution(end).Thickness - mdb.results.TransientSolution(end).Thickness)) ./ (1e9) .* 0.9167);
    fprintf('int(H_Weertman_tn - H_Budd_tn) = %.1f\n', integrate_field_spatially(mdw, abs(mdw.results.TransientSolution(end).Thickness - mdb.results.TransientSolution(end).Thickness)) ./ (1e9) .* 0.9167);
    fprintf('int(H_Weertman_tn - H_Schoof_tn) = %.1f\n', integrate_field_spatially(mdw, abs(mdw.results.TransientSolution(end).Thickness - mds.results.TransientSolution(end).Thickness)) ./ (1e9) .* 0.9167);


    vel_b = cell2mat({mdb.results.TransientSolution(:).Vel});
    vel_s = cell2mat({mds.results.TransientSolution(:).Vel});
    vel_w = cell2mat({mdw.results.TransientSolution(:).Vel});
    vel_b = mean(vel_b(cell2mat({mdb.results.TransientSolution(:).time}) > 2005 & cell2mat({mdb.results.TransientSolution(:).time}) < 2010), 2);
    vel_s = mean(vel_s(cell2mat({mds.results.TransientSolution(:).time}) > 2005 & cell2mat({mds.results.TransientSolution(:).time}) < 2010), 2);
    vel_w = mean(vel_w(cell2mat({mdw.results.TransientSolution(:).time}) > 2005 & cell2mat({mdw.results.TransientSolution(:).time}) < 2010), 2);

    vel_misfit1 = integrate_field_spatially(md0, abs(md0.inversion.vel_obs - vel_b)) .* 1e-9;
    vel_misfit2 = integrate_field_spatially(md0, abs(md0.inversion.vel_obs - vel_s)) .* 1e-9;
    vel_misfit3 = integrate_field_spatially(md0, abs(md0.inversion.vel_obs - vel_w)) .* 1e-9;

    title1 = sprintf('Budd, MAE=%.1f', vel_misfit1);%mean(abs(md0.inversion.vel_obs - vel_b)));
    title2 = sprintf('Schoof, MAE=%.1f', vel_misfit2);%mean(abs(md0.inversion.vel_obs - vel_s)));
    title3 = sprintf('Weertman, MAE=%.1f', vel_misfit3);%mean(abs(md0.inversion.vel_obs - vel_w)));
    plotmodel(md0, 'data', md0.inversion.vel_obs - vel_b, ...
                'data', md0.inversion.vel_obs - vel_s, ...
                'data', md0.inversion.vel_obs - vel_w, ...
                'caxis#all', [-8e2 8e2], 'mask#all', mdb.results.TransientSolution(end).MaskIceLevelset<0, ...
                'title#1', title1, 'title#2', title2, 'title#3', title3, ...
                'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
                'colorbar#1-2', 'off', ...
                'axis#all', axes, 'figure', 90); colormap('turbo'); 
                exportgraphics(gcf, fullfile('.', 'Vel_misfit.png'), 'Resolution', 300)
    
end