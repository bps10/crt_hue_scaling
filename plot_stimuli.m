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
    nstim = length(stim_params(:, 6));
    for s = 1:nstim
        plot([back(1), stim_params(s, 6)], [back(2), stim_params(s, 7)], 'ko-')
    end

    plots.save_fig(fullfile('img', 'stim', params.exp_stim_type,...
        'CIE_stim'), f1);

    % 
    f2 = figure;
    hold on;

    purities = unique(stim_params(:, 2));
    for p = 1:length(purities)
        s_params = stim_params(stim_params(:, 2) == purities(p), :);
        plot(s_params(:, 1), s_params(:, 3), 'r-o', 'linewidth', 2);
        plot(s_params(:, 1), s_params(:, 4), 'g-o', 'linewidth', 2);
        plot(s_params(:, 1), s_params(:, 5) * 0.5, 'b-o', 'linewidth', 2);
    end

    text(s_params(7, 1) - 45, s_params(7, 5) * 0.5 - 5, 'S-cone (x0.5)', ...
        'fontsize', 20)
    text(s_params(1, 1) + 10, s_params(1, 4) - 5, 'M-cone', 'fontsize', 20)
    text(s_params(3, 1) + 10, s_params(3, 3) - 9, 'L-cone', 'fontsize', 20)

    plots.nice_axes('color angle', 'cone contrast', 20);

    xlim([min(stim_params(:, 1)) max(stim_params(:, 1))])
    %set(gca, 'ytick', -50:25:50)

    plots.save_fig(fullfile('img', 'stim', params.exp_stim_type, ...
        'cone_contrast'), f2);

end