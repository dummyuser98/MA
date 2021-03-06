%% choose data / regularizer / optimization scheme
clear all, close all, clc;

% 1. choose data from {'rect', 'hand'}
data = 'rect';

% 2. choose regularizer from {'diffusive', 'curvature'}
regularizer = 'curvature';

% 3. choose optimizer from {'gradient_descent', 'newton'}
optimizer = 'newton';

%% initialization

R = double(imread(sprintf('%s1.png', data)));
T = double(imread(sprintf('%s2.png', data)));
[m, n] = size(R);
h = [1, 1];

% display reference and template image
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
colormap gray(256);

subplot(2, 2, 1);
image(...
    'Xdata', [h(1) / 2, (n - (1 / 2)) * h(1)], ...
    'YData', [h(2) / 2, (m - (1 / 2)) * h(2)], ...
    'CData', flipud(R));
axis xy;
axis image;
colorbar;
xlabel('---x-->');
ylabel('---y-->');
title('reference R');

subplot(2, 2, 2);
image(...
    'Xdata', [h(1) / 2, (n - (1 / 2)) * h(1)], ...
    'YData', [h(2) / 2, (m - (1 / 2)) * h(2)], ...
    'CData', flipud(T));
axis xy;
axis image;
colorbar;
xlabel('---x-->');
ylabel('---y-->');
title('template T');

%% registration procedure

% set function handles for data term, regularizer and final objective
dist_fctn = @(T, R, h, u) SSD(T, R, h, u);

if strcmp(regularizer, 'curvature')
    reg_fctn = @(u, s, h) curvature_energy(u, s, h);
elseif strcmp(regularizer, 'diffusive')
    reg_fctn = @(u, s, h) diffusive_energy(u, s, h);
end

lambda = 2e4;
f = @(u) objective_function(dist_fctn, reg_fctn, lambda, T, R, h, u);

% optimization procedure
u0 = zeros(m * n * 2, 1);
if strcmp(optimizer, 'gradient_descent')
    u_star = gradient_descent(f, u0);
elseif strcmp(optimizer, 'newton')
    u_star = newton_scheme(f, u0);
end

% evaluate result
u_star = reshape(u_star, [m*n, 2]);
T_u_star = evaluate_displacement(T, h, u_star);

% compute grid g from displacement u
[cc_x, cc_y] = cell_centered_grid([m, n], h);
g = [cc_x(:), cc_y(:)] + u_star;
g = reshape(g, [m, n, 2]);

%% display results

subplot(2, 2, 3);
image(...
    'Xdata', [h(1) / 2, (n - (1 / 2)) * h(1)], ...
    'YData', [h(2) / 2, (m - (1 / 2)) * h(2)], ...
    'CData', flipud(T));
axis xy;
axis image;
colorbar;
xlabel('---x-->');
ylabel('---y-->');
plot_grid(g);
title('template T with displaced grid')

subplot(2, 2, 4);
image(...
    'Xdata', [h(1) / 2, (n - (1 / 2)) * h(1)], ...
    'YData', [h(2) / 2, (m - (1 / 2)) * h(2)], ...
    'CData', flipud(T_u_star));
axis xy;
axis image;
colorbar;
xlabel('---x-->');
ylabel('---y-->');
title('transformed template T_u');