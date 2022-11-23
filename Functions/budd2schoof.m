function [md] = budd2schoof(md, coeffs, cs_min, cs_max)
    % md = loadmodel("/data/eigil/work/lia_kq/Models/baseline/Model_kangerlussuaq_friction.mat");

    % Budd's Friction coefficient from inversion
    CB = md.friction.coefficient;
    
    % Compute the basal velocity
    ub = (md.results.StressbalanceSolution.Vx.^2+md.results.StressbalanceSolution.Vy.^2).^(0.5)./md.constants.yts;
    ub(md.mask.ice_levelset>0) = nan; % remove no ice region
    % exponents in Budd's lawDZ6b7#rG
    
    r = 1;
    s = 1;
    CS_min = cs_min;
    CS_max = cs_max;

    % To compute the effective pressure
    p_ice   = md.constants.g*md.materials.rho_ice*md.geometry.thickness;
    p_water = md.materials.rho_water*md.constants.g*(0-md.geometry.base);
    % water pressure can not be positive
    p_water(p_water<0) = 0;
    % effective pressure
    Neff = p_ice - p_water;
    Neff(Neff<md.friction.effective_pressure_limit) = md.friction.effective_pressure_limit;

    % basal shear stress from Budd's law
    taub = CB.^2.*Neff.^r.*ub.^s;

    % Schoof's law
    n = 3.0;  % from Glen's flow law
    m = 1.0/n;
    Cmax = coeffs(4); % Iken's bound, scalar in this case for simplicity

    % Compute the friction coefficient of Schoof's law
    CS = (1./(ub./(taub.^n)-ub./((Cmax.*Neff)).^n) ).^(1/n);

    % For the area violate Iken's bound, extrapolate or interpolate from
    % surrongdings.
    flags = (taub>=Cmax.*Neff);
    pos1  = find(flags);
    pos2  = find(~flags);
    %= griddata(md.mesh.x(pos2),md.mesh.y(pos2),md.friction.coefficient(pos2),md.mesh.x(pos1),md.mesh.y(pos1));
    CS = CS.^0.5;
    CS(pos1) = CS_max;

    % No ice
    pos = find(isnan(CS));
    CS(pos)  = CS_max;

    % set to Schoof's law
    md.friction = frictionschoof();
    md.friction.C = CS;  % Schoof's law has been changed with C^2 as the coefficient
    md.friction.Cmax = Cmax*ones(md.mesh.numberofvertices,1);
    md.friction.m = m*ones(md.mesh.numberofelements,1);
    md.friction.coupling = 2;

    % %No friction on PURELY ocean element
    % pos_e = find(min(md.mask.ice_levelset(md.mesh.elements),[],2)<0);
    % flags=ones(md.mesh.numberofvertices,1);
    % flags(md.mesh.elements(pos_e,:))=0;
    % md.friction.C(find(flags))=100;

    %Control general
    md.inversion=m1qn3inversion(md.inversion);
    md.inversion.iscontrol=1;
    md.verbose=verbose('solution',false,'control',true);
    md.transient.amr_frequency = 0;

    %Cost functions
    md.inversion.cost_functions=[101 103 501];
    md.inversion.cost_functions_coefficients=zeros(md.mesh.numberofvertices,numel(md.inversion.cost_functions));
    md.inversion.cost_functions_coefficients(:,1) = coeffs(1); % 4000;
    md.inversion.cost_functions_coefficients(:,2) = coeffs(2); % 1.5;
    md.inversion.cost_functions_coefficients(:,3) = coeffs(3); % 2e-8;
    
    % remove non-ice and nans from misfit in cost function (will only rely on regularisation)
    pos = find(md.mask.ice_levelset > 0);
    md.inversion.cost_functions_coefficients(pos, 1:2) = 0;

    pos = find(isnan(md.inversion.vel_obs) | md.inversion.vel_obs == 0);
    md.inversion.cost_functions_coefficients(pos, 1:2) = 0;

    %Controls
    md.inversion.control_parameters={'FrictionC'};
    md.inversion.maxsteps=100;
    md.inversion.maxiter =100;
    md.inversion.min_parameters=CS_min*ones(md.mesh.numberofvertices,1);
    md.inversion.max_parameters=CS_max*ones(md.mesh.numberofvertices,1);
    md.inversion.control_scaling_factors=1;
    md.inversion.gttol = 1e-3;
    md.inversion.dxmin = 1e-20;
    %Additional parameters
    md.stressbalance.restol=0.01;
    md.stressbalance.reltol=0.1;
    md.stressbalance.abstol=NaN;

    %Go solve
    md=solve(md, 'sb');

    %Put results back into the model
    md.friction.C = md.results.StressbalanceSolution.FrictionC;
    md.initialization.vx = md.results.StressbalanceSolution.Vx;
    md.initialization.vy = md.results.StressbalanceSolution.Vy;

    % save 'model_extrapolated_friction.mat' md;
    % plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'figure', 43); %exportgraphics(gcf, 'vel.png')
    % plotmodel(md, 'data', md.results.StressbalanceSolution.FrictionC, 'figure', 44); %exportgraphics(gcf, 'vel.png')
end