function [] = gradient_distributions(mb_struct_path)
    % load mass balance curve
    mass_balance_curve_struct = load(mb_struct_path, 'mass_balance_curve_struct');
    mass_balance_curve_struct = mass_balance_curve_struct.mass_balance_curve_struct;
    mb = mass_balance_curve_struct.mass_balance{1};
    mb_time = mass_balance_curve_struct.time{1};
    mb_gradient = gradient(mb, mb_time);

    % load retreat/advance vector
    dist_analysis = load("/data/eigil/work/lia_kq/Data/validation/flowline_positions/distance_analysis.mat", 'distance_analysis');
    dist_analysis = dist_analysis.distance_analysis;                                                                              
    gradient_interp = dist_analysis.gradient_interp;                                                                              
    gradient_sign = dist_analysis.gradient_sign;
    time_interp = dist_analysis.time_interp;     
    
    [xx1, yy1, xx2, yy2, grad1, grad2] = plot_background(time_interp, gradient_sign, [-400, 150], gradient_interp);
    grad1 = grad1(1:end-1);
    cmin = min(abs(horzcat(grad1, grad2)));
    cmax = max(abs(horzcat(grad1, grad2)));
    c1 = (grad1 - cmin)/(cmax - cmin);
    c2 = (grad2 - cmin)/(cmax - cmin);

    advance_N = size(grad1, 2);
    green = [0, 1, 0];
    light_green = [231, 255, 231]/255;
    greens = flipud([linspace(green(1), light_green(1), advance_N)', linspace(green(2), light_green(2), advance_N)', linspace(green(3), light_green(3), advance_N)']);

    retreat_N = size(grad2, 2);
    red = [1, 0, 0];
    pink = [255, 231, 231]/255;
    reds = ([linspace(red(1), pink(1), retreat_N)', linspace(red(2), pink(2), retreat_N)', linspace(red(3), pink(3), retreat_N)']);

    figure(1)
    colormap([greens; reds])
    c1 = c1 * advance_N;
    c2 = c2 * retreat_N + advance_N + 1;

    p1 = patch(xx1, yy1, c1, 'FaceAlpha', 1, 'EdgeColor','none');
    hold on 
    p2 = patch(xx2, yy2, c2, 'FaceAlpha', 1, 'EdgeColor','none');

    plot(mb_time, mb_gradient, 'color', 'k')
    ylim([-400, 150])
    xlim([1899.5, 2021.5])
    ylabel('Mass balance gradient [Gt/yr]')
    xlabel('Year')
    set(gca,'FontSize',14) % Creates an axes and sets its FontSize to 18
    hold off


    figure(2)
    subplot(1, 3, 1)
    histogram(mb_gradient(gradient_sign<0), 100, 'FaceColor', 'red', 'FaceAlpha', 0.3, 'EdgeColor','none'); % retreat
    hold on                                                                              
    histogram(mb_gradient(gradient_sign>0), 100, 'FaceColor', 'green', 'FaceAlpha', 0.3, 'EdgeColor','none'); % advance
    legend([sprintf("$\\mathrm{Retreat}, \\mu=%.2f$", mean(mb_gradient(gradient_sign<0))), sprintf("$\\mathrm{Advance}, \\mu=%.2f$", mean(mb_gradient(gradient_sign>0)))], 'Interpreter', 'latex', 'Location', 'NorthWest')
    ylabel('Count')
    xlabel('Mass balance gradient [Gt/yr]')
    title('Distribution for full time span')
    set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18

    time_after_1985 = mb_time > 1990 & mb_time <= 2000;
    mb_1985 = mb_gradient(time_after_1985);
    gradient_sign_1985 = gradient_sign(time_after_1985); 

    subplot(1, 3, 2)
    histogram(mb_1985(gradient_sign_1985<0), 100, 'FaceColor', 'red', 'FaceAlpha', 0.3, 'EdgeColor','none'); % retreat
    hold on                                                                              
    histogram(mb_1985(gradient_sign_1985>0), 100, 'FaceColor', 'green', 'FaceAlpha', 0.3, 'EdgeColor','none'); % advance
    legend([sprintf("$\\mathrm{Retreat}, \\mu=%.2f$", mean(mb_1985(gradient_sign_1985<0))), sprintf("$\\mathrm{Advance}, \\mu=%.2f$", mean(mb_1985(gradient_sign_1985>0)))], 'Interpreter', 'latex', 'Location', 'NorthWest')
    ylabel('Count')
    xlabel('Mass balance gradient [Gt/yr]')
    title('Distribution after 1985')
    set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18

    time_after_1985 = mb_time > 2000 & mb_time <= 2010;
    mb_1985 = mb_gradient(time_after_1985);
    gradient_sign_1985 = gradient_sign(time_after_1985); 

    subplot(1, 3, 2)
    histogram(mb_1985(gradient_sign_1985<0), 100, 'FaceColor', 'red', 'FaceAlpha', 0.3, 'EdgeColor','none'); % retreat
    hold on                                                                              
    histogram(mb_1985(gradient_sign_1985>0), 100, 'FaceColor', 'green', 'FaceAlpha', 0.3, 'EdgeColor','none'); % advance
    legend([sprintf("$\\mathrm{Retreat}, \\mu=%.2f$", mean(mb_1985(gradient_sign_1985<0))), sprintf("$\\mathrm{Advance}, \\mu=%.2f$", mean(mb_1985(gradient_sign_1985>0)))], 'Interpreter', 'latex', 'Location', 'NorthWest')
    ylabel('Count')
    xlabel('Mass balance gradient [Gt/yr]')
    title('Distribution after 1985')
    set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18


    time_after_2015 = mb_time > 2010;
    mb_2015 = mb_gradient(time_after_2015);
    gradient_sign_2015 = gradient_sign(time_after_2015);

    subplot(1, 3, 3)
    histogram(mb_2015(gradient_sign_2015<0), 100, 'FaceColor', 'red', 'FaceAlpha', 0.3, 'EdgeColor','none'); % retreat
    hold on                                                                              
    histogram(mb_2015(gradient_sign_2015>0), 100, 'FaceColor', 'green', 'FaceAlpha', 0.3, 'EdgeColor','none'); % advance
    legend([sprintf("$\\mathrm{Retreat}, \\mu=%.2f$", mean(mb_2015(gradient_sign_2015<0))), sprintf("$\\mathrm{Advance}, \\mu=%.2f$", mean(mb_2015(gradient_sign_2015>0)))], 'Interpreter', 'latex', 'Location', 'NorthWest')
    ylabel('Count')
    xlabel('Mass balance gradient [Gt/yr]')
    title('Distribution after 2010')
    set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
end