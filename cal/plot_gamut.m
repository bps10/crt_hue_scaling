cal_data = csvread('data/calibration_raw_data.csv');
cal.describe.nMeas = 16;

% Load default calibration file:
T_xyz1931 = csvread('data/ciexyz31.csv')';
S_xyz1931 = [380, 5, 81];

CMFs = SplineCmf(S_xyz1931, T_xyz1931, [380 1 401]);
% guns_xyz = guns' * CMFs';
% guns_xyz = diag(1 ./ sum(guns_xyz, 2)) * guns_xyz;  
    
% ---- Subtract off ambient light from each measurment
corrected_xyz = zeros(16 * 3, 3);
uncorrected_xyz = zeros(16 * 3, 3);
k = 1;
for i=0:2
    ambient_index = 2 + i * (16 + 1);
    ambient = cal_data(:, ambient_index);
    for j=1:16
        
        ind = ambient_index + j;
        un_xyz = cal_data(:, ind);
        cor_xyz = cal_data(:, ind) - ambient;
        cor_xyz = cor_xyz' * CMFs';
        corrected_xyz(k, :)  = diag(1 ./ sum(cor_xyz, 2)) * cor_xyz;
        un_xyz = un_xyz' * CMFs';
        uncorrected_xyz(k, :) = diag(1 ./ sum(un_xyz, 2)) * un_xyz;
        k = k + 1;
    end
end


xyz = diag(1 ./ sum(T_xyz1931, 1)) * T_xyz1931';
figure(1); 
plot(xyz(:, 1), xyz(:, 2), 'k-', 'LineWidth', 2); hold on;

%plot(corrected_xyz(:, 1), corrected_xyz(:, 2), '.', 'MarkerSize', 30);
plot(uncorrected_xyz(:, 1), uncorrected_xyz(:, 2), '.', 'MarkerSize', 30);

axis square
xlim([0, 0.9]);
ylim([0, 0.9]);
set(gca,'fontsize', 20, 'linewidth', 1, 'TickDir', 'out', ...
    'TickLength', [0.05 0.0]);
box off;
xlabel('x');
ylabel('y');
