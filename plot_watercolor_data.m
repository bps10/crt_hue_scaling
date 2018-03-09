function plot_watercolor_data(params, data)

data = util.remove_zero_rows(data);

pInit.b = 4;
pInit.t = mean(params.purity_vals);   

answer = data(:, 8) > 0;

figure;
count = 1;
thresholds = zeros(length(params.angles), 1);
for a = 1:length(params.angles)
    angle = params.angles(a);
    pp = 0.3;
    p_seen_summary = zeros(length(params.purity_vals), 1);
    for p = 1:length(params.purity_vals)
        purity = params.purity_vals(p);
        
        subplot(4, 2, count);     
        hold on;
        title(['hue angle: ' num2str(angle)]);
        
        ind = data(:, 1) == angle & data(:, 2) == purity;
        this_answer = answer(ind);
        
        N = length(this_answer);
        p_seen = sum(this_answer) / N;
        p_seenSEM = sqrt(p_seen * (1 - p_seen) / N);
        
        errorbar(params.purity_vals(p), p_seen, p_seenSEM, 'k-')
        scat = scatter(params.purity_vals(p), p_seen, 'ko', 'markerfacecolor', 'k');
        scat.MarkerFaceAlpha = pp;
        
        xlim([min(params.purity_vals) max(params.purity_vals)])
        ylim([0 1])
        
        p_seen_summary(p) = p_seen;
        
        pp = pp + 0.2;
        
    end
    
    count = count + 1;
    
    % now add FoS
    % fit a psychometric function
    results.intensity = params.purity_vals';
    results.response = p_seen_summary;   
    pBest = stats.fit_psychometric_func(results, pInit, 'k', [], ...
        [], 'weibull');

    thresholds(a) = pBest.t;   
    xlabel('');
    ylabel('');    
end

subplot(4, 2, 7);
xlabel('color purity')
ylabel('% seen')

subplot(4, 2, 8);
xlabel('color purity')

figure;
plot(params.angles, thresholds, 'ko-')
plots.nice_axes('hue angles', '50% FoS')

%%%%
figure;
count = 1;
thresholds = zeros(length(params.angles), 1);
for a = 1:length(params.angles)
    angle = params.angles(a);
    pp = 0.3;
    p_seen_summary = zeros(length(params.purity_vals), 1);
    for p = 1:length(params.purity_vals)
        purity = params.purity_vals(p);
        
        subplot(4, 2, count);     
        hold on;
        title(['hue angle: ' num2str(angle)]);
        
        ind = data(:, 1) == angle & data(:, 2) == purity;
        this_data = data(ind, :);
        
        N = length(this_data(:, 8));
        
        p_seen = mean(this_data(:, 8) ./ 5);
        p_seenSEM = std(this_data(:, 8) ./ 5) / sqrt(N);
        
        errorbar(params.purity_vals(p), p_seen, p_seenSEM, 'k-')
        scat = scatter(params.purity_vals(p), p_seen, 'ko', 'markerfacecolor', 'k');
        scat.MarkerFaceAlpha = pp;
        
        xlim([min(params.purity_vals) max(params.purity_vals)])
        ylim([0 1])
        
        p_seen_summary(p) = p_seen;
        
        pp = pp + 0.2;
        
    end
    
    count = count + 1;
    
    % now add FoS
    % fit a psychometric function
    results.intensity = params.purity_vals';
    results.response = p_seen_summary;     
    pBest = stats.fit_psychometric_func(results, pInit, 'k', [], ...
        [], 'weibull');

    thresholds(a) = pBest.t;   
    xlabel('');
    ylabel('');    
end

subplot(4, 2, 7);
xlabel('color purity')
ylabel('% seen')

subplot(4, 2, 8);
xlabel('color purity')

figure;
plot(params.angles, thresholds, 'ko-')
plots.nice_axes('hue angles', '50% FoS')