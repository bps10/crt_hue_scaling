function plot_hue_scaling(data, params)

% plot results
f = figure; hold on;
plots.format_uad_axes();
names = {'red', 'green', 'blue', 'yellow', 'white'};

angles = unique(data(:, 1));
purities = unique(data(:, 2));
summary = zeros(length(angles) * length(purities), 6);
c = 1;
for p = 1:length(purities)
    purity = purities(p);    
    for a = 1:length(angles)
        angle = angles(a);
        d = data(data(:, 1) == angle & data(:, 2) == purity, 7:12);

        [by, rg] = color_naming.data_uad(d, names);
        mean_by = mean(by);
        mean_rg = mean(rg);
        std_by = std(by) / sqrt(length(by));
        std_rg = std(rg) / sqrt(length(rg));
        
        summary(c, 1) = angle;
        summary(c, 2) = purity;
        summary(c, 3:6) = [mean_by, mean_rg, std_by, std_rg];

        
        text(mean_by, mean_rg, num2str(angle), 'fontsize', 15);
        %plot([0, mean_by], [0, mean_rg], 'k-');

        plots.errorbarxy(mean_by, mean_rg, std_by, std_rg, ...
            {'ko', 'k', 'k'});
        
        c = c + 1;
    end
    % add a connecting ring
    plot(summary(summary(:, 2) == purity, 3), ...
        summary(summary(:, 2) == purity, 4),...
        'k-', 'linewidth', 1.5);
end
set(gca, 'FontSize', 22);

% f = figure; hold on; box off;
% plots.format_uad_axes();
% 
% plots.errorbarxy(summary(:, 3), summary(:, 4), ...
%     summary(:, 5), summary(:, 6), {'ko-', 'k', 'k'});
% 
% plot([summary(1, 3), summary(end-1, 3)], ...
%     [summary(1, 4) summary(end-1, 4)], 'k-')
% text(summary(:, 3), summary(:, 4), num2str(angles), 'fontsize', 15);
% 
% for angle = 0:90:270
%     ind = angles == angle;
%     x = [0, summary(ind, 3)];
%     y = [0, summary(ind, 4)];
%     
%     %plots.arrow(x, y, 2.3);
%     plot(x, y, 'linewidth', 2, 'color', 'k');
% end

plots.save_fig(fullfile('img', params.subject_id, ['UAD_' date]), f);