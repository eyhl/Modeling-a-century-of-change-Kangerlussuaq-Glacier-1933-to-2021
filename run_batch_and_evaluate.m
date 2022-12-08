function [] = run_batch_and_evaluate(axes)

    config_b = 'config-8dec-budd.csv';
    config_cb = 'config-8dec-control-budd.csv';
    config_s = 'config-8dec-schoof.csv';
    config_cs = 'config-8dec-control-schoof.csv';
    config_w = 'config-8dec-weertman.csv';
    config_cw = 'config-8dec-control-weertman.csv';

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

    % mdb = loadmodel('Models/dec6_budd1/Model_kangerlussuaq_transient_budd.mat');                                                                                      
    % mds = loadmodel('Models/dec6_budd1/Model_kangerlussuaq_transient_schoof.mat');
    % mdw = loadmodel('Models/dec6_budd1/Model_kangerlussuaq_transient_weertman.mat');
    % mdc = loadmodel('Models/dec6_budd1/Model_kangerlussuaq_transient_control.mat'); 
    md_list = [mdb, mds, mdw];
    md_control_list = [mdcb, mdcs, mdcw];
    md_names = {'Budd', 'Budd control', 'Schoof', 'Schoof control', 'Weertman', 'Weertman control'};

    compare_models(mdb, mds, mdw, mdc, '.')  
    md0 = loadmodel('Models/Model_kangerlussuaq_budd.mat');

    title1 = sprintf('Budd, MAE=%.1f', mean(abs(md0.geometry.thickness - mdb.results.TransientSolution(end).Thickness)));
    title2 = sprintf('Schoof, MAE=%.1f', mean(abs(md0.geometry.thickness - mds.results.TransientSolution(end).Thickness)));
    title3 = sprintf('Weertman, MAE=%.1f', mean(abs(md0.geometry.thickness - mdw.results.TransientSolution(end).Thickness)));

    plotmodel(md0, 'data', md0.geometry.thickness - mdb.results.TransientSolution(end).Thickness, ...
                'data', md0.geometry.thickness - mds.results.TransientSolution(end).Thickness, ...
                'data', md0.geometry.thickness - mdw.results.TransientSolution(end).Thickness, ...
                'caxis#all', [-2e2 2e2], 'mask', mdb.results.TransientSolution(end).MaskIceLevelset<0, ...
                'title#1', title1, 'title#2', title2, 'title#3', title3, ...
                'xticks', [], 'yticks', [], ...
                'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], ...
                'axis#all', axes); exportgraphics(gcf, fullfile('.', 'H_misfit.png'), 'Resolution', 300)

end