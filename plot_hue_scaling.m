function plot_hue_scaling(data)

% plot results
figure; hold on;
plots.format_uad_axes();
names = {'red', 'green', 'blue', 'yellow', 'white'};

angles = unique(data(:, 1));
summary = zeros(length(angles), 4);
for a = 1:length(angles)
    angle = angles(a);
    d = data(data(:, 1) == angle, 6:11);
    
    [by, rg] = color_naming.data_uad(d, names);
    mean_by = mean(by);
    mean_rg = mean(rg);
    std_by = std(by) / sqrt(length(by));
    std_rg = std(rg) / sqrt(length(rg));
    summary(a, :) = [mean_by, mean_rg, std_by, std_rg];
    
    text(mean_by, mean_rg, num2str(angle), 'fontsize', 15);
    plot([0, mean_by], [0, mean_rg], 'k-');
    
    plots.errorbarxy(mean_by, mean_rg, std_by, std_rg, ...
        {'ko', 'k', 'k'});
end
set(gca, 'FontSize', 22);

f = figure; hold on; box off;
plots.format_uad_axes();

plots.errorbarxy(summary(:, 1), summary(:, 2), ...
    summary(:, 3), summary(:, 4), {'ko-', 'k', 'k'});

plot([summary(1, 1), summary(end-1, 1)], ...
    [summary(1, 2) summary(end-1, 2)], 'k-')
text(summary(:, 1), summary(:, 2), num2str(angles), 'fontsize', 15);

for angle = 0:90:270
    ind = angles == angle;
    x = [0, summary(ind, 1)];
    y = [0, summary(ind, 2)];
    
    %plots.arrow(x, y, 2.3);
    plot(x, y, 'linewidth', 2, 'color', 'k');
end

plots.save_fig(fullfile('img', params.subject_id, 'UAD'), f);