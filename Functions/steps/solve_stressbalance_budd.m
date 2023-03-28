function [md] = solve_stressbalance_budd(md, coefs, cb_min, cb_max, velocity_exponent)
    if nargin < 5
        velocity_exponent = 1;
    end
    md = sethydrostaticmask(md);

    % fix floating hole
    pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/floating_hole.exp', 2));
    md.mask.ocean_levelset(pos) = 100;
    % md = make_floating(md);

    % Control general
    md.inversion = m1qn3inversion(md.inversion);
    md.inversion.iscontrol = 1;
    md.verbose = verbose('solution', false, 'control', true);

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

    pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/ignore_tip_of_domain.exp', 2));
    % md.inversion.cost_functions_coefficients(pos, 1:2) = 0;

    % % floating ice (done automatically in C++)
    % pos = find(md.mask.ice_levelset<0 & md.mask.ocean_levelset<0);
    % md.inversion.cost_functions_coefficients(pos, 1:2) = 0;

    % optional: weighed velocity
    if velocity_exponent ~= 1
        % vel = md.results.StressbalanceSolution.Vel./md.constants.yts; %velocity in m/s
        % C = md.friction.C;
        % m = md.friction.m(1); 
        % tau_b = C.^2 .* vel.^(1/m);

        % %Convert to Budd
        % N = md.constants.g .* (md.materials.rho_ice .* md.geometry.thickness + md.materials.rho_water * md.geometry.base);
        % N = max(0, N);
        % md.friction = friction();

        md.friction.p = velocity_exponent .* ones(md.mesh.numberofelements, 1);
        md.friction.q = velocity_exponent .* ones(md.mesh.numberofelements, 1); % N^(p/q) so to only scale v, q=p

        % md.friction.coefficient = sqrt(tau_b./(N .* vel.^(1/velocity_exponent)));
        % md.friction.coefficient = min(md.friction.coefficient, 10);

        % pos = md.mask.ocean_levelset < 0;
        % md.friction.coefficient(pos) = cb_min;
        % Use standard Budd soln as initial guess, requires a conversion solving the two equations
        % tau_b = C^2 * N * v_b
        % tau_b = C_plastic^2 * N * v_b^(1/5)
        % C_plastic = C * v_b ^(2/5)
        md.friction.coefficient = md.results.StressbalanceSolution.FrictionCoefficient .* (md.results.StressbalanceSolution.Vel./md.constants.yts).^(2./5);
        md.friction.coefficient = min(md.friction.coefficient, cb_max);
        % pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/ignore_tip_of_domain.exp', 2));
        % md.friction.coefficient(pos) = cb_max;
        % md.friction.coefficient = averaging(md, md.friction.coefficient, 1);
        % md.friction.coefficient = rescale(md.friction.coefficient, 0.01, 100);
    end

    %Controls
    md.inversion.control_parameters={'FrictionCoefficient'};
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
    md.friction.coefficient = md.results.StressbalanceSolution.FrictionCoefficient;
    md.initialization.vx = md.results.StressbalanceSolution.Vx;
    md.initialization.vy = md.results.StressbalanceSolution.Vy;
    md.initialization.vel = md.results.StressbalanceSolution.Vel;

    % Save present day inversion results in misc (If SB is recomputed for LIA these are lost)
    md.miscellaneous.dummy.J = md.results.StressbalanceSolution.J;
    md.miscellaneous.dummy.Adjointx = md.results.StressbalanceSolution.Adjointx;
    md.miscellaneous.dummy.Adjointy = md.results.StressbalanceSolution.Adjointy;
    md.miscellaneous.dummy.FrictionCoefficient = md.results.StressbalanceSolution.FrictionCoefficient;
    md.miscellaneous.dummy.Gradient1 = md.results.StressbalanceSolution.Gradient1;
end
