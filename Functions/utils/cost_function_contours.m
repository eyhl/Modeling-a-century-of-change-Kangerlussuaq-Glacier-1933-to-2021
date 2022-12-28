function [] = cost_function_contours()
    N = 225;
    n_alpha = 15
    J = zeros(N, 1);
    alpha = zeros(N, 1);
    c_max = zeros(N, 1);

    for i = 2:N + 1
        fprintf("Loading md%d.mat\n", i);

        md = loadmodel(sprintf("Results/grid_search_schoof/schoof10/models/md%d.mat", i));

        % extract 
        J(i - 1) = md.results.StressbalanceSolution.J(end, end); % get Total J
        alpha(i - 1) = max(unique(md.inversion.cost_functions_coefficients(:, 3))); % get alpha
        c_max(i - 1) = unique(md.friction.Cmax(:, 1)); % get c_max

    end

    J = reshape(J, n_alpha, n_alpha);
    alpha = reshape(alpha, n_alpha, n_alpha);
    c_max = reshape(c_max, n_alpha, n_alpha);
    

    figure(678);
    contourf(alpha, c_max, J, 10);
    c = colorbar;
    c.Label.String = '$\mathcal{J}$';
    c.Label.Interpreter = 'latex';
    c.Label.FontSize = 15;
    xlabel('$\alpha$', 'fontsize', 15,'Interpreter','latex')
    ylabel('$C_{max}$', 'fontsize', 15,'Interpreter','latex')
    exportgraphics(gcf, "cost_function_contours.png", 'Resolution', 300);

    figure(679);
    surfc(alpha, c_max, J);
    c = colorbar;
    c.Label.String = '$\mathcal{J}$';
    c.Label.Interpreter = 'latex';
    c.Label.FontSize = 15;
    xlabel('$\alpha$', 'fontsize', 15,'Interpreter','latex')
    ylabel('$C_{max}$', 'fontsize', 15,'Interpreter','latex')
end