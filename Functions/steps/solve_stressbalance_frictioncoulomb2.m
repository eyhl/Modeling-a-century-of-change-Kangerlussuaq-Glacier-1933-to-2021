function md = solve_stressbalance_frictioncoulomb2(md, m, coefs, cb_min, cb_max)
   u0 = coefs(4);

   %compute horizontal velocity, basal friction
   ub=sqrt(md.initialization.vx.^2+md.initialization.vy.^2)./md.constants.yts;
   p_ice   = md.constants.g*md.materials.rho_ice*md.geometry.thickness;
   p_water = max(0.,md.materials.rho_water*md.constants.g*(0-md.geometry.base));
   N = p_ice - p_water;
   pos=find(N<=0); N(pos)=1;

   s=averaging(md,1./md.friction.p,0);
   r=averaging(md,md.friction.q./md.friction.p,0);
   b=(md.friction.coefficient).^2.*(N.^r).*(ub.^s);
   alpha2=md.friction.coefficient.^2.*N.^r.*ub.^(s-1);

   %new friction coefficient
   md.friction=frictionregcoulomb2();
   u1=(u0./md.constants.yts).^(1./m)./N;
   p=1;
   C=b./((ub./(ub+(u1.*N).^m)).^(1./m).*(N.^p));

   %pos1 = find(md.mask.ice_levelset>0);
   %pos2 = find(md.mask.ice_levelset<=0);
   pos1 = find(isnan(C));
   pos2 = find(~isnan(C));
   C(pos1) = griddata(md.mesh.x(pos2),md.mesh.y(pos2),C(pos2),md.mesh.x(pos1),md.mesh.y(pos1),'nearest');
   %C(pos1)=Kriging(md.mesh.x(pos2),md.mesh.y(pos2),C(pos2),md.mesh.x(pos1),md.mesh.y(pos1),'output','idw','boxlength',150,'searchradius',10000);
   %pos=find(ub==0 | N==0); C(pos)=0;

   md.friction.K=u1.*ones(md.mesh.numberofvertices,1);
   md.friction.m=m.*ones(md.mesh.numberofelements,1);
   %md.friction.p=p;
   md.friction.C=C;


   %Cost functions
   md.inversion.cost_functions = [101 103 501];
   md.inversion.cost_functions_coefficients = zeros(md.mesh.numberofvertices, numel(md.inversion.cost_functions));
   md.inversion.cost_functions_coefficients(:,1) = coefs(1);
   md.inversion.cost_functions_coefficients(:,2) = coefs(2);
   md.inversion.cost_functions_coefficients(:,3) = coefs(3);
   
   % remove non-ice and nans from misfit in cost function (will only rely on regularisation)
   pos = find(md.mask.ice_levelset > 0);
   md.inversion.cost_functions_coefficients(pos, 1:2) = 0;

   pos = find(isnan(md.inversion.vel_obs) | md.inversion.vel_obs == 0);
   md.inversion.cost_functions_coefficients(pos, 1:2) = 0;
    %Controls
    md.inversion.control_parameters={'FrictionC'};
    md.inversion.maxsteps = 200;
    md.inversion.maxiter = 200;
    md.inversion.min_parameters = cb_min * ones(md.mesh.numberofvertices, 1);
    md.inversion.max_parameters = cb_max * ones(md.mesh.numberofvertices, 1);
    md.inversion.control_scaling_factors = 1;
    md.inversion.dxmin = 1e-30;
    md.inversion.gttol = 1e-20;

    %Additional parameters
    md.stressbalance.restol = 0.01; % mechanical equilibrium residual convergence criterion
    md.stressbalance.reltol = 0.1; % velocity relative convergence criterion
    md.stressbalance.abstol = NaN; % velocity absolute convergence criterion (NaN=not applied)

    % Solve
    md=solve(md, 'Stressbalance');

    % Put results back into the model
    md.results.StressbalanceSolution
    md.friction.coefficient = md.results.StressbalanceSolution.FrictionCoefficient;
    md.initialization.vx = md.results.StressbalanceSolution.Vx;
    md.initialization.vy = md.results.StressbalanceSolution.Vy;
    md.initialization.vel = md.results.StressbalanceSolution.Vel;

    % Save present day inversion results in misc (If SB is recomputed for LIA these are lost)
    md.miscellaneous.dummy.J = md.results.StressbalanceSolution.J;
    md.miscellaneous.dummy.Adjointx = md.results.StressbalanceSolution.Adjointx;
    md.miscellaneous.dummy.Adjointy = md.results.StressbalanceSolution.Adjointy;
    md.miscellaneous.dummy.FrictionC = md.results.StressbalanceSolution.FrictionCoefficient;
    md.miscellaneous.dummy.Gradient1 = md.results.StressbalanceSolution.Gradient1;

end