function [total_misfit, model_norm, alphas, kappa] = l_curve_analysis(data_path, fix_up, n_alphas)
    %% load data
    data_table = readtable(data_path);
    
    if nargin < 2
        fix_up = false;
        n_alphas = height(data_table);
    end

    if nargin < 3
        n_alphas = height(data_table);
    end

    
    %% chunk data
    N = height(data_table) / n_alphas;
    
    k = 1;
    for i = 1:N
        alphas = data_table.Var5(i + n_alphas * (i - 1) : n_alphas +  n_alphas * (i - 1));
        misfit = data_table.Var6(i + n_alphas * (i - 1) : n_alphas +  n_alphas * (i - 1));
        log_misfit = data_table.Var7(i + n_alphas * (i - 1) : n_alphas +  n_alphas * (i - 1));
        model_norm = data_table.Var8(i + n_alphas * (i - 1) : n_alphas +  n_alphas * (i - 1));

        model_norm = model_norm ./ alphas;
        total_misfit = misfit + log_misfit;

        if fix_up
            M = movmean(model_norm, fix_up);
            model_norm = M;
            % x_s = linspace(min(x), max(x), 1000);
            % vq = interp1(M(index:end), M(index:end), x_s, 'linear');

            model_norm = model_norm(1:end);
            total_misfit = total_misfit(1:end);
            alphas = alphas(1:end);
            % disp(ignore_point_index)
        end

        [reg_corner, ireg_corner, kappa] = l_curve_corner(total_misfit, model_norm, alphas);


        figure(90 + k)
        loglog(total_misfit, model_norm, 'LineStyle', 'none', 'Marker', '+')
        hold on
        % scatter(total_misfit(ireg_corner), model_norm(ireg_corner), 'ro')
        % disp(total_misfit(ireg_corner))
        % plot(synthetic_data, data_model, 'r');
        % title_string = sprintf('corner $\\alpha=$%.2E, misfit $\\mathcal{J}_0=%.2f$', reg_corner, total_misfit(ireg_corner));
        % set(get(gca, 'Title'), 'interpreter', 'latex', 'String', title_string);

        % voffset = (1 + exp(-linspace(-10, 20, n_alphas)))' .* model_norm;
        voffset = 0.1 * model_norm;
	    hoffset = 0.1 * total_misfit;
        text(total_misfit + hoffset, model_norm + voffset,[repmat('\alpha = ',length(alphas),1) num2str(alphas(:),'%2.0e')],...
		'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','Middle')
        xlabel('$\mathrm{log}(\mathcal{J}_0$)','Interpreter','latex')
        ylabel('$\mathrm{log}(\mathcal{R})$','Interpreter','latex')
        k = k + 1;

        hold off
        % figure(293);         plot(synthetic_data, data_model, 'r');

    end

    %% compute all l curves and plot them. 

end
    % INPUT
%   rho       - misfit
%   eta       - model norm or seminorm
%   reg_param - the regularization parameter
%
% OUTPUT
%   reg_corner  - the value of reg_param with maximum curvature
%   ireg_corner - the index of the value in reg_param with maximum curvature
%   kappa       - the curvature for each reg_param
%
% function [reg_corner,ireg_corner,kappa]=l_curve_corner(rho,eta,reg_param)