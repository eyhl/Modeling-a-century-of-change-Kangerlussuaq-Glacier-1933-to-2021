function [] = search_schoof_initial_state()
        cs_min = 0.001;
        xl = [4.478, 5.152]*1e5;
        yl = [-2.3239, -2.2563]*1e6;
        res = 250;
        N_models = 225;
        for i=2:N_models+1
            disp(i-1)
            model = sprintf('md%d.mat', i);
            file_name = sprintf('Results/grid_search_schoof/schoof10/models/%s', model);
            md = loadmodel(file_name);

            %% Parameterize at LIA
            md = parameterize(md, 'ParameterFiles/transient_lia.par');
            validate_flag = true;

            %% Correlation extrapolation
            M = 6; % polynomial order
            [extrapolated_friction, extrapolated_pos, mae_poly] = friction_correlation_model(md, cs_min, M, 'schoof', false); 
            
            % set values under cs min to cs min
            extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
            
            md.friction.C(extrapolated_pos) = extrapolated_friction;

            %% Solve
            md.inversion.iscontrol = 0;
            md = solve(md, 'sb');

            % PLOT INITIAL STATE:
            plotmodel(md, 'data', log(md.friction.C)./log(10), 'title', 'FC', ...
            'data', md.results.StressbalanceSolution.Vel, 'xtick', [], 'ytick', [], 'figure', 666, ...
            'ylim#all', yl, 'xlim#all', xl); 
            set(gca,'fontsize',10);
            colormap('turbo'); 
            exportgraphics(gcf, sprintf('%s_corr_extrp.png', model), 'Resolution', res)

            %% Constant extrapolation
            [extrapolated_friction, extrapolated_pos, mae_const] = friction_constant_model(md, cs_min, 'schoof', false);

            %% Solve
            md.inversion.iscontrol = 0;
            md = solve(md, 'sb');
            
            % PLOT INITIAL STATE:
            plotmodel(md, 'data', log(md.friction.C)./log(10), 'title', 'FC', ...
            'data', md.results.StressbalanceSolution.Vel, 'xtick', [], 'ytick', [], 'figure', 667, ...
            'ylim#all', yl, 'xlim#all', xl); 
            set(gca,'fontsize',10);
            colormap('turbo'); 
            exportgraphics(gcf, sprintf('%s_const_extrp.png', model), 'Resolution', res)
        end
end