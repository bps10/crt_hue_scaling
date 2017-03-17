function plot_cal_data(cal)

if nargin < 1
    cal = LoadCalFile('RoordaProjectorMar4');
end

colorCycle = [1 0 0; 0 0.6 0; 0 0 1];

figure(1); clf;

% Change to new colors.
set(gca, 'ColorOrder', colorCycle, ...
    'NextPlot', 'replacechildren');

plot(SToWls(cal.S_device), cal.P_device, 'LineWidth', 2.5);
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Power',  'FontSize', 20);
title('Primaries', 'Fontsize', 20, 'Fontname', 'helvetica');
axis([380, 780, -Inf, Inf]);
set(gca,'fontsize', 20, 'linewidth', 1, 'TickDir', 'out', ...
    'TickLength', [0.05 0.0]);
box off;

figure(2);

T_xyz1931 = csvread('data/ciexyz31.csv')';
S_xyz1931 = [380, 5, 81];

CMFs = SplineCmf(S_xyz1931, T_xyz1931, [380 1 401]);
%wvlens = SToWls(cal.S_device);

cor_xyz = cal.P_device' * CMFs';        
gun_xyz  = diag(1 ./ sum(cor_xyz, 2)) * cor_xyz;

xyz = diag(1 ./ sum(CMFs, 1)) * CMFs';

plot(xyz(:, 1), xyz(:, 2), 'k-', 'LineWidth', 2); hold on;
plot(gun_xyz(:, 1), gun_xyz(:, 2), 'k.', 'MarkerSize', 30);
plot(gun_xyz(:, 1), gun_xyz(:, 2), 'k--', 'LineWidth', 2.5);
plot([gun_xyz(1, 1) gun_xyz(3, 1)], ...
    [gun_xyz(1, 2) gun_xyz(3, 2)], 'k--', 'LineWidth', 2.5);
    
axis square
xlim([0, 0.9]);
ylim([0, 0.9]);
set(gca,'fontsize', 20, 'linewidth', 1, 'TickDir', 'out', ...
    'TickLength', [0.05 0.0]);
box off;
xlabel('x');
ylabel('y');


figure(3); clf;
set(gca, 'ColorOrder', colorCycle, ...
    'NextPlot', 'replacechildren');
plot(cal.rawdata.rawGammaInput, cal.rawdata.rawGammaTable, '+', ...
    'MarkerSize', 20);
xlabel('Input value', 'FontSize', 20);
ylabel('Normalized output', 'FontSize', 20);
title('Gamma functions', 'Fontsize', 20, 'Fontname', 'helvetica');
hold on
plot(cal.gammaInput, cal.gammaTable, 'LineWidth', 2);
hold off
figure(gcf);
set(gca,'fontsize', 20, 'linewidth', 1, 'TickDir', 'out', ...
    'TickLength', [0.05 0.0]);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);
box off;
drawnow;
