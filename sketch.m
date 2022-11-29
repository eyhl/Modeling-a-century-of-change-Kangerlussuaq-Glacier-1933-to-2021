function sketch(axes)
    plot_no = 3;
    file_path = 'Results/grid_search_schoof/schoof_init_search2/';
    table = readtable([file_path, 'coef_settings_schoof.txt']);

    cmax066 = table(table.Var3 == 0.66, :);                                                                      
    cmax074 = table(table.Var3 == 0.74, :);                                                                      
    cmax077 = table(table.Var3 == 0.77, :);
    cmax081 = table(table.Var3 == 0.81, :);
    cmax084 = table(table.Var3 == 0.84, :);
    cmax090 = table(table.Var3 == 0.90, :);

    data = {cmax066, cmax074, cmax077, cmax081, cmax084, cmax090};

    if plot_no == 1
        loglog(cmax066.Var5, cmax066.Var7 / 2500 + cmax066.Var8 ./ cmax066.Var5, 'LineStyle', 'none', 'Marker', 'x'); ylabel('log(J0 / C_2)'); xlabel('log(C_2)'); 
        hold on;
        loglog(cmax074.Var5, cmax074.Var7 / 2500 + cmax074.Var8 ./ cmax074.Var5, 'LineStyle', 'none', 'Marker', 'o');
        loglog(cmax077.Var5, cmax077.Var7 / 2500 + cmax077.Var8 ./ cmax077.Var5, 'LineStyle', 'none', 'Marker', 'square');
        loglog(cmax081.Var5, cmax081.Var7 / 2500 + cmax081.Var8 ./ cmax081.Var5, 'LineStyle', 'none', 'Marker', 'diamond');
        loglog(cmax084.Var5, cmax084.Var7 / 2500 + cmax081.Var8 ./ cmax084.Var5, 'LineStyle', 'none', 'Marker', '*');
        loglog(cmax090.Var5, cmax090.Var7 / 2500 + cmax090.Var8 ./ cmax090.Var5, 'LineStyle', 'none', 'Marker', 'x');
        legend('Cmax=0.66', 'Cmax=0.74', 'Cmax=0.77', 'Cmax=0.81', 'Cmax=0.84', 'Cmax=0.90')
        hold off;
    elseif plot_no == 2
        alphas = load('Results/grid_search_schoof/schoof_init_search2/coefficient_3.mat').coefficient_3;
        Cmax_list = unique(table.Var3);

        for i=1:length(data)
            figure(i)
            % get the log misfit coefficients
            C2 = unique(data{i}.Var5);

            % compute J0, correct for coefficients
            J0 = data{i}.Var9 / 2500 + data{i}.Var10 ./ data{i}.Var5;
            R = data{i}.Var11 ./ data{i}.Var6;
            % J0_LIA = data{i}.Var7 / 2500 + data{i}.Var8 ./ data{i}.Var5;

            for k=1:length(C2)
                % extract current log misfit coefficient
                c2 = C2(k);

                % extract J0 misfit corresponding to C2
                j0 = J0(data{i}.Var5 == c2);
                r = R(data{i}.Var5 == c2);
                % j0_lia = (J0_LIA(data{i}.Var5 == c2) - min(j0)) / (max(j0) - min(j0)) ;

                % L-curve
                % [reg_corner, ireg_corner, kappa] = l_curve_corner(j0, r, alphas);

                subplot(2, 5, k)
                loglog(j0, r, 'LineStyle', 'none', 'Marker', '+')
                hold on
                % loglog(j0_lia, r, 'LineStyle', 'none', 'Marker', 'o')
                voffset = 0.1 * r;
                hoffset = 0.1 * j0;
                text(j0 + hoffset, r + voffset,[repmat('\alpha = ',length(alphas),1) num2str(alphas(:),'%2.0e')],...
                'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','Middle')
                xlabel('$\mathrm{log}(\mathcal{J}_0$)','Interpreter','latex')
                ylabel('$\mathrm{log}(\mathcal{R})$','Interpreter','latex')
                % title(sprintf('$C_{max}=%.2f, C_2=%.2f$', Cmax_list(i), c2),'Interpreter','latex');
                hold off
            end
        end
    elseif plot_no == 3
        alphas = load('Results/grid_search_schoof/schoof_init_search2/coefficient_3.mat').coefficient_3;
        n_alphas = length(alphas);
        C2 = load('Results/grid_search_schoof/schoof_init_search2/coefficient_2.mat').coefficient_2;
        Cmax_list = unique(table.Var3);
        Cmax_names = {'cmax_0.66', 'cmax_0.74', 'cmax_0.77', 'cmax_0.81', 'cmax_0.84', 'cmax_0.90'};
        m = 1; 

        for i=1:length(data) % x6
            cmax_name = ['Results/grid_search_schoof/schoof_init_search2/', Cmax_names{i}, '/'];
            files = natsortfiles(dir(cmax_name));
            files = files(~ismember({files.name}, {'.','..'}));
            directoryNames = {files.name};

            for j=1:length(C2)
                model_struct = {};
                for k=1:n_alphas          
                    model_name = [cmax_name, directoryNames{k + (j - 1) * n_alphas}]        
                    model_struct{k} = loadmodel(model_name);
                end
                tmp_table = table(table.Var3 == Cmax_list(i), :);  
                tmp_table = tmp_table(tmp_table.Var5 == C2(j), :);                                                              

                bulk_plotting(model_struct, sprintf('$C_{max}=%.2f, C_2=%d$', Cmax_list(i), C2(j)), m, 250, tmp_table, axes, [-1e3, 1e3; -1e-3, 1e-3]);
                m = m + 1;
            end

            % LOAD ALL CMAX PATH NAMES
            % FOR i=1:length(Cmax_list) x10
            %       FOR i=1:15 x15
            %           LOAD 15 MODELS
            %           PLACE IN STRUCT
            %       END
            %       PLOT 15 FILES AT A TIME: CONSTRUCT 
            %       GO TO NEXT FIGURE


            % for k=1:length(C2)
            %     figure(m + 1)
            %     c1
            %     c2
            %     c3
            %     cmax
            %     [file_path, sprintf('md%d_%.2f_%d_%d_%.2g.mat', 1 + n_alphas * m, )]

            %     m = m + 1;
            % end
        end

    end

end