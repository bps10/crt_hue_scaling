function [params] = hue_scaling_params(params)
    import white.*
    
% from the De Valois et al. 1997 paper (Table 1)
angles = [0 28 53 73 90 110 130 155 180 208 233 253 270 290 310 335];
Lcontrast = [8.6 7.6 5.15 2.5 0.0 -2.9 -5.5 -7.8 -8.6 -7.6 -5.15 -2.5 ...
    0.0 2.9 5.5 7.8];
Mcontrast = [-16.4 -14.5 -9.9 -4.8 0.0 5.6 10.5 14.8 16.4 14.5 9.9 4.8 ...
    0.0 -5.6 -10.5 -14.8];
Scontrast = [0.0 39.2 66.7 79.8 83.5 78.5 64.0 35.3 0.0 -39.2 -66.7 -79.8 ...
    -83.5 -78.5 -64.0 -35.3];
x = [0.3819 0.3464 0.3151 0.2913 0.2724 0.2521 0.2349 0.2205 0.2197 0.2459 ...
    0.2992 0.3528 0.3926 0.4204 0.4257 0.4099];
y = [0.2826 0.2458 0.2290 0.2251 0.2280 0.2392 0.2595 0.2998 0.3584 0.4402 ...
    0.5043 0.5238 0.5092 0.4627 0.4033 0.3355];

params.stim_params = [angles; Lcontrast; Mcontrast; Scontrast; x; y]';

background = [0.310, 0.316, 18]; % cd/m2

params.ncolors = length(angles); 

params.x = x;
params.y = y;
params.lum = background(3);
params.background = background;

params.angles = angles;

params.Lcontrast = Lcontrast;
params.Mcontrast = Mcontrast;
params.Scontrast = Scontrast;                

params.ntrials = params.ncolors * params.nrepeats;

params.trial_xyY = zeros(params.ntrials, 5);

% create a vector of indicies based on number of stim & repeats
indices = repmat(1:length(angles), params.nrepeats);
indices = indices(:);
% randomize
rand_ind = randperm(length(indices));
params.trial_ind = indices(rand_ind);


end