function [H_update, mean_step, m, v] = adam_step(g, m, v, i, beta_1, beta_2)
    m(:, i) = beta_1 .* m(:, i-1) + (1 - beta_1) .* g;
    v(:, i) = beta_2 .* v(:, i-1) + (1 - beta_2) .* g.^2;
    mhat = m(:, i) ./ (1.0 - beta_1 .^ (i-1));
    vhat = v(:, i) ./ (1.0 - beta_2 .^ (i-1));
    mean_step = mean(mhat, 1)/(mean(sqrt(vhat), 1) + eps);
    H_update = mhat ./ (sqrt(vhat) + eps) .* abs(g);
end