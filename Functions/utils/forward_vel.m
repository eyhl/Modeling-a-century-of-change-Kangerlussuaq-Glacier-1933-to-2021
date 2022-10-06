% md = loadmodel('Models/Model_kangerlussuaq_friction.mat');
% md = fill_in_texture(md);
% md = parameterize(md, 'ParameterFiles/lia.par');
md = loadmodel('Models/Model_kangerlussuaq_lia_domain.mat');
md = fill_in_texture(md);

md = sethydrostaticmask(md);
md.inversion.iscontrol=0;
md = solve(md, 'Stressbalance');

% save 'model_extrapolated_friction.mat' md;
plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'figure', 2); %exportgraphics(gcf, 'vel.png')
plotmodel(md, 'data', md.friction.coefficient, 'figure', 3, 'caxis', [0 100]); %exportgraphics(gcf, 'vel.png')
