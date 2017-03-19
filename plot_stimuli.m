function plot_stimuli(params, cal)    

    % color space (fundamentals) are set in cal_struct: currently JuddVos
    CMFs = cal.T_sensor;

    % validate that correct fundamentals are being used
    check_fundamentals = false;
    if check_fundamentals
        load T_xyzJuddVos
        figure;
        plot(SToWls(cal.S_device), cal.T_sensor'); hold on; 
        plot(SToWls(S_xyzJuddVos), T_xyzJuddVos', '+')
    end
    f1 = figure;
    cor_xyz = cal.P_device' * CMFs';        
    gun_xyz  = diag(1 ./ sum(cor_xyz, 2)) * cor_xyz;

    % normalize to sum to 1, i.e. tristimulus values
    xyz = diag(1 ./ sum(CMFs, 1)) * CMFs';

    % add outline of space and phospher locations to the plot
    plot(xyz(:, 1), xyz(:, 2), 'k-', 'LineWidth', 2); hold on;
    plot(gun_xyz(:, 1), gun_xyz(:, 2), 'k.', 'MarkerSize', 30);
    plot(gun_xyz(:, 1), gun_xyz(:, 2), 'k--', 'LineWidth', 2.5);
    plot([gun_xyz(1, 1) gun_xyz(3, 1)], ...
        [gun_xyz(1, 2) gun_xyz(3, 2)], 'k--', 'LineWidth', 2.5);

    axis square
    xlim([0, 0.9]);
    ylim([0, 0.9]);
    set(gca,'fontsize', 20, 'linewidth', 1, 'TickDir', 'out', ...
        'TickLength', [0.025 0.0]);
    box off;
    plots.nice_axes('x', 'y', 20);

    % add the stimuli to the plot
    stim_params = params.stim_params;
    back = params.background;
    nstim = length(stim_params(:, 5));
    for s = 1:nstim
        plot([back(1), stim_params(s, 5)], [back(2), stim_params(s, 6)], 'ko-')
    end

    plots.save_fig(fullfile('img', 'stim', 'CIE_stim', ...
        params.exp_stim_type), f1);

    % 
    f2 = figure;
    hold on;

    plot(stim_params(:, 1), stim_params(:, 2), 'r-o', 'linewidth', 2);
    plot(stim_params(:, 1), stim_params(:, 3), 'g-o', 'linewidth', 2);
    plot(stim_params(:, 1), stim_params(:, 4) * 0.5, 'b-o', 'linewidth', 2);

    text(stim_params(5, 1) + 10, stim_params(5, 4) * 0.5 + 2, 'S-cone (x0.5)', ...
        'fontsize', 20)
    text(stim_params(9, 1) + 10, stim_params(9, 3) + 3, 'M-cone', 'fontsize', 20)
    text(stim_params(10, 1) + 10, stim_params(10, 2) - 3, 'L-cone', 'fontsize', 20)

    plots.nice_axes('color angle', 'cone contrast', 20);

    xlim([min(stim_params(:, 1)) max(stim_params(:, 1))])
    set(gca, 'ytick', -50:25:50)

    plots.save_fig(fullfile('img', 'stim', 'cone_contrast', ...
        params.exp_stim_type), f2);

end