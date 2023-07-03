function [] = quickCheckInversion(md)
    axs = 1e6 .* [0.422302857764172   0.510073291293409  -2.303227021597650  -2.230919592486114];

    fprintf('Misfit level: %f\n', sum(md.results.StressbalanceSolution.J(end, 1:2)))

    % plot velocity misfit and gradient 
    v_misfit = md.results.StressbalanceSolution.Vel - md.inversion.vel_obs;
    c_val1 = 1000;
    grad = md.results.StressbalanceSolution.Gradient1;
    c_val2 = max([min(abs(grad(:))), max(abs(grad(:)))]);
    plotmodel(md, 'data', v_misfit, 'title', 'V_m - V_obs', 'caxis#1', [-c_val1 c_val1], 'axis#1', axs,...
                  'data', grad, 'title', 'Gradient', 'caxis#2', [-c_val2 c_val2], 'axis#2', axs, ...
                  'data', v_misfit, 'caxis#3', [-c_val1 c_val1], ...
                  'data', grad, 'caxis#4', [-c_val2 c_val2], 'mask#all', md.mask.ice_levelset<0, 'xtick#all', [], 'ytick#all', [])

end