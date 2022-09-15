% x = 2;
% y = 2;
clear all; clc; close all;
% define range for input
r_min = -1.0;
r_max = 1.0;
x_range = r_min:0.1:r_max;
y_range = r_min:0.1:r_max;
[x, y] = meshgrid(x_range, y_range);

result = objective(x, y);

figure(1);
surf(x, y, result)

rng(3)
alpha = 0.02;
% factor for average gradient
beta_1 = 0.8;
% factor for average squared gradient
beta_2 = 0.999;

bounds = [-1.0 1.0; -1.0 1.0];
xaxis = bounds(1, 1):0.1:bounds(1, 2);
yaxis = bounds(2, 1):0.1:bounds(2, 2);


[best, score, solutions] = adam(bounds, alpha, beta_1, beta_2);

[x, y] = meshgrid(xaxis, yaxis);
result = objective(x, y);
figure(2);
contourf(x, y, result);
hold on
plot(solutions(2, :), solutions(1, :), 'w', 'LineWidth', 3)

%% Optimization 
function [x, score, solutions] = adam(bounds, alpha, beta_1, beta_2)
    n_iter = 100;

    eps = 1e-8;
    % generate intiatial point
    x = bounds(:, 1) + rand(length(bounds), 1) .* (bounds(:, 2) - bounds(:, 1));
    score = objective(x(1), x(2));

    % initialise first and second moments
    m = zeros(2, 1);
    v = zeros(2, 1);

    solutions = zeros(size(bounds, 1), n_iter);

    for t=1:n_iter
        g = derivative(x(1), x(2));
        for i=1:length(x)
            % m(t) = beta1 * m(t-1) + (1 - beta1) * g(t)
            m(i) = beta_1 .* m(i) + (1 - beta_1) .* g(i);
            
            % v(t) = beta2 * v(t-1) + (1 - beta2) * g(t)^2
            v(i) = beta_2 .* v(i) + (1 - beta_2) .* g(i).^2;

            % mhat(t) = m(t) / (1 - beta1(t))
            mhat = m(i) ./ (1.0 - beta_1 .^ (t + 1));

            % vhat(t) = v(t) / (1 - beta2(t))
            vhat = v(i) ./ (1.0 - beta_2 .^ (t + 1));

            % x(t) = x(t-1) - alpha * mhat(t) / (sqrt(vhat(t)) + eps)
            x(i) = x(i) - alpha .* mhat ./ (sqrt(vhat) + eps);
        end
        score = objective(x(1), x(2));
        fprintf("%d f(%.2f, %.2f) = %.5f\n", t, x(1), x(2), score);

        solutions(:, t) = x;
    end
end

function [out] = objective(x, y)
    out = x.^2 + y.^2;
end

function [out] = derivative(x, y)
    out = [2 .* x, 2 .* y];
end
