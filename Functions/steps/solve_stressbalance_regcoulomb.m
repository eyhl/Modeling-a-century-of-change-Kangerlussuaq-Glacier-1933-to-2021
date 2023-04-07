function [md] = solve_stressbalance_regcoulomb(md, coeffs, cr_min, cr_max, initial_guess)
    % Regularised Coulomb law
    m = 3.0;
    u0 = coeffs(4)/md.constants.yts; % Iken's bound, scalar in this case for simplicity

    if nargin < 5
        % Compute the basal velocity
        ub = (md.results.StressbalanceSolution.Vx.^2+md.results.StressbalanceSolution.Vy.^2).^(0.5)./md.constants.yts;
        % ub(md.mask.ice_levelset>0) = nan; % remove no ice region

        % To compute the effective pressure
        p_ice   = md.constants.g*md.materials.rho_ice*md.geometry.thickness;
        p_water = md.materials.rho_water*md.constants.g*(0-md.geometry.base);
        % water pressure can not be positive
        p_water(p_water<0) = 0;
        % effective pressure
        Neff = p_ice - p_water;
        Neff(Neff<md.friction.effective_pressure_limit) = md.friction.effective_pressure_limit;
        
        r = 1;
        s = 1;

        %% BUDD INITIAL GUESS
        % % Budd's Friction coefficient from inversion
        % CB = md.friction.coefficient;

        % % basal shear stress from Budd's law
        % taub = CB.^2.*Neff.^r.*ub.^s;

        % % Compute the squared friction coefficient of regularised coulombs law
        % CR = CB .* sqrt(Neff) .* ub .^ ((m - 1) / (2 * m)) .* (abs(ub) ./ u0 + 1) .^ (1 / (2 * m));  % similar to sqrt(taub * (ub / (ub/u0 + 1)) ^ (-1/m))
        % CR = min(CR, cr_max);

        % % % No ice
        % pos = find(isnan(CR));
        % CR(pos)  = cr_max;

        %% SCHOOF INITAL GUESS
        % Schoof's Friction coefficient from inversion
        Cmax = 0.8114;
        CS = md.friction.C;

        taub = CS.^2 .* ub.^(1/m - 1) ./ (1 + (CS.^2 ./ (Cmax * Neff)).^(m) .* ub).^(1/m);

        % Compute the squared friction coefficient of regularised coulombs law
        CR = sqrt(taub .* (ub ./ (ub / u0 + 1)).^(-1/m));  % similar to sqrt(taub * (ub / (ub/u0 + 1)) ^ (-1/m))
        % CR = min(CR, cr_max);

        % % No ice
        pos = find(isnan(CR));
        CR(pos)  = cr_max;

        pos = find(isinf(CR));
        CR(pos)  = cr_max;
    else
        CR = initial_guess;
    end

    % set to Regularized Coulomb law
    md.friction = frictionregcoulomb();
    md.friction.C = CR;  
    md.friction.u0 = u0;
    md.friction.m = m*ones(md.mesh.numberofelements,1);
 
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
    md.inversion.maxsteps=400;
    md.inversion.maxiter =400;
    md.inversion.min_parameters=cr_min*ones(md.mesh.numberofvertices,1);
    md.inversion.max_parameters=cr_max*ones(md.mesh.numberofvertices,1);
    md.inversion.control_scaling_factors=1;
    md.inversion.gttol = 1e-20;
    md.inversion.dxmin = 1e-30;
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
    md.initialization.vel = md.results.StressbalanceSolution.Vel;

    % Save present day inversion results in misc (If SB is recomputed for LIA these are lost)
    md.miscellaneous.dummy.J = md.results.StressbalanceSolution.J;
    md.miscellaneous.dummy.Adjointx = md.results.StressbalanceSolution.Adjointx;
    md.miscellaneous.dummy.Adjointy = md.results.StressbalanceSolution.Adjointy;
    md.miscellaneous.dummy.FrictionC = md.results.StressbalanceSolution.FrictionC;
    md.miscellaneous.dummy.Gradient1 = md.results.StressbalanceSolution.Gradient1;


    % save 'model_extrapolated_friction.mat' md;
    % plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'figure', 43); %exportgraphics(gcf, 'vel.png')
    % plotmodel(md, 'data', md.results.StressbalanceSolution.FrictionC, 'figure', 44); %exportgraphics(gcf, 'vel.png')
end