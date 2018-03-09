function [params] = hue_scaling_params(params, cal)
  
    if strcmpi(params.exp_stim_type, 'devalois')
        % from the De Valois et al. 1997 paper (Table 1)
        params.angles = [0 28 53 73 90 110 130 155 180 208 233 253 270 290 310 335];
        params.Lcontrast = [8.6 7.6 5.15 2.5 0.0 -2.9 -5.5 -7.8 -8.6 -7.6 -5.15 -2.5 ...
            0.0 2.9 5.5 7.8];
        params.Mcontrast = [-16.4 -14.5 -9.9 -4.8 0.0 5.6 10.5 14.8 16.4 14.5 9.9 4.8 ...
            0.0 -5.6 -10.5 -14.8];
        params.Scontrast = [0.0 39.2 66.7 79.8 83.5 78.5 64.0 35.3 0.0 -39.2 -66.7 -79.8 ...
            -83.5 -78.5 -64.0 -35.3];
        params.x = [0.3819 0.3464 0.3151 0.2913 0.2724 0.2521 0.2349 0.2205 0.2197 0.2459 ...
            0.2992 0.3528 0.3926 0.4204 0.4257 0.4099];
        params.y = [0.2826 0.2458 0.2290 0.2251 0.2280 0.2392 0.2595 0.2998 0.3584 0.4402 ...
            0.5043 0.5238 0.5092 0.4627 0.4033 0.3355];
        
        params.background = [0.310, 0.316, 18]; % cd/m2
        
    else
        %params.angles = [0 28 53 73 90 110 130 155 180 208 233 253 270 290 310 335];        
        params.angles = 0:45:359;
        
        % The following is adapted from Psychtoolboxes DKLDemo 
        whichCones = 'SmithPokorny';

        % Load spectral data and set calibration file
        switch (whichCones)
            case 'SmithPokorny'
                load T_cones_sp
                load T_xyzJuddVos
                S_cones = S_cones_sp;
                T_cones = T_cones_sp;
                T_Y = 683*T_xyzJuddVos(2,:);
                S_Y = S_xyzJuddVos;
                T_Y = SplineCmf(S_Y,T_Y,S_cones);
            case 'StockmanSharpe'
                load T_cones_ss2
                load T_ss2000_Y2
                S_cones = S_cones_ss2;
                T_cones = T_cones_ss2;
                T_Y = 683*T_ss2000_Y2;
                S_Y = S_ss2000_Y2;
                T_Y = SplineCmf(S_Y,T_Y,S_cones);
        end

        calLMS = SetSensorColorSpace(cal, T_cones, S_cones);
        calLMS = SetGammaMethod(calLMS,1);
        calLum = SetSensorColorSpace(cal, T_Y, S_Y);

        % Define background: rgb [0.25 0.2 0.2 = xyY [0.3139 0.3246 40.67]
        %bgLMS = PrimaryToSensor(calLMS, [0.25 0.2 0.2]');
        bgLMS = PrimaryToSensor(calLMS, [0.9 0.9 0.9]');

        % Get matrix that transforms between incremental
        % cone coordinates and DKL coordinates 
        % (Lum, RG, S).
        M_ConeIncToDKL = ComputeDKL_M(bgLMS, T_cones, T_Y);
        M_DKLToConeInc = inv(M_ConeIncToDKL);

        % Now find incremental cone directions corresponding
        % to DKL isoluminant directions.
        rgConeInc = M_DKLToConeInc * [0 1 0]';
        sConeInc = M_DKLToConeInc * [0 0 1]';
        
        % These directions are not scaled in an interesting way,
        % need to scale them.  Here we'll find units so that 
        % a unit excursion in the two directions brings us to
        % the edge of the monitor gamut, with a little headroom.
        bgPrimary = SensorToPrimary(calLMS, bgLMS);
        rgPrimaryInc = SensorToPrimary(calLMS, rgConeInc + bgLMS) - bgPrimary;
        sPrimaryInc = SensorToPrimary(calLMS, sConeInc + bgLMS) - bgPrimary;
        rgScale = MaximizeGamutContrast(rgPrimaryInc, bgPrimary);
        sScale = MaximizeGamutContrast(sPrimaryInc, bgPrimary);
        rgConeInc = 0.95 * rgScale * rgConeInc;
        sConeInc = 0.95 * sScale * sConeInc;

        % now find rg and s vals for all stimuli at all purity levels       
        params.npurity_vals = length(params.purity_vals);
        rgVals = [];
        sVals = [];
        for sat = 1:params.npurity_vals
            saturation = params.purity_vals(sat);
            [rg, s] = pol2cart(deg2rad(params.angles), saturation);
            rgVals = [rgVals rgConeInc * rg];
            sVals = [sVals sConeInc * s];
        end
               
        % If we find the RGB values corresponding to unit excursions
        % in rg and s directions, we should find a) that the luminance
        % of each is the same and b) that they are all within gamut.
        % In gamut means that the primary coordinates are all bounded
        % within [0,1].
        rgPlusLMS = bgLMS+rgConeInc;
        rgMinusLMS = bgLMS-rgConeInc;
        sPlusLMS = bgLMS+sConeInc;
        sMinusLMS = bgLMS-sConeInc;
        rgPlusPrimary = SensorToPrimary(calLMS,rgPlusLMS);
        rgMinusPrimary = SensorToPrimary(calLMS,rgMinusLMS);
        sPlusPrimary = SensorToPrimary(calLMS,sPlusLMS);
        sMinusPrimary = SensorToPrimary(calLMS,sMinusLMS);
        if (any([rgPlusPrimary(:) ; rgMinusPrimary(:) ; ...
                sPlusPrimary(:) ; sMinusPrimary(:)] < 0))
            fprintf('Something out of gamut low that shouldn''t be.\n');
        end
        if (any([rgPlusPrimary(:) ; rgMinusPrimary(:) ; ...
                sPlusPrimary(:) ; sMinusPrimary(:)] > 1))
            fprintf('Something out of gamut high that shouldn''t be.\n');
        end
        
        bgLum = PrimaryToSensor(calLum,bgPrimary);
        rgPlusLum = PrimaryToSensor(calLum,rgPlusPrimary);
        rgMinusLum = PrimaryToSensor(calLum,rgMinusPrimary);
        sPlusLum = PrimaryToSensor(calLum,sPlusPrimary);
        sMinusLum = PrimaryToSensor(calLum,sMinusPrimary);
        lums = sort([bgLum rgPlusLum rgMinusLum sPlusLum sMinusLum]);
        fprintf('Luminance range in isoluminant plane is %0.2f to %0.2f\n',...
            lums(1), lums(end));      
        
        % percent contrast is relative to background
        params.Lcontrast = rgVals(1, :) ./ bgLMS(1) * 100;
        params.Mcontrast = rgVals(2, :) ./ bgLMS(2) * 100;
        params.Scontrast = sVals(3, :) ./ bgLMS(3) * 100;

        % now convert to xyY. 
        conv_mat = T_cones_sp' \ T_xyzJuddVos';
        lms = zeros(size(rgVals'));
        for ii = 1:size(rgVals, 2)
            lms(ii, :) = [rgVals(1:2, ii); sVals(3, ii)] + bgLMS;
        end
        xyz = lms * conv_mat;        
        xyz = diag(1 ./ sum(xyz, 2)) * xyz;
        
        % add to params
        params.x = xyz(:, 1)';
        params.y = xyz(:, 2)';                
        
        % convert background
        bg_xyz = bgLMS' * conv_mat;
        bg_xyz = bg_xyz / sum(bg_xyz);
        
        % add background as xyY
        params.background = [bg_xyz(1) bg_xyz(2) bgLum];
    end 
    
    params.stim_params = [repmat(params.angles, ...
        [1, params.npurity_vals]); reshape(repmat(params.purity_vals, ...
        [length(params.angles), 1]), [1, length(params.x)]);
        params.Lcontrast; ...
        params.Mcontrast; params.Scontrast; params.x; params.y]';    

    params.ncolors = length(params.angles); 
    params.lum = params.background(3);            

    params.ntrials = params.ncolors * params.nrepeats * params.npurity_vals;

    % create a vector of indicies based on number of stim & repeats
    indices = repmat(1:length(params.angles) * params.npurity_vals, ...
        params.nrepeats);
    indices = indices(:);
    % randomize
    rand_ind = randperm(length(indices));
    params.trial_ind = indices(rand_ind);

end