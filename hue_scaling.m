clearvars; close all;

% ---- Set parameters for experiment or display stimulus
params.subject_id = 'test';

params.stimulus_shape = 'circle';
params.exp_stim_type = 'dkl';

params.img_x = 50;
params.img_y = 50;

params.img_offset_x = 100;
params.img_offset_y = 100;

params.flash_duration = 0.5; % in sec

params.nkeypresses = 5;
params.nrepeats = 3;

params.screen = 0;

params.cal_file = 'Feb13_2014a.mat';
params.cal_dir = 'cal/files';

params.debug_mode = 1;

% ---- Load calibration file:
cal = cal_struct(params.cal_file, params.cal_dir);

% get hue specific parameters
params = hue_scaling_params(params, cal); 
    
data = zeros(params.ntrials, 11);

try
    % ---- Set up window
    [window, oldVisualDebugLevel, oldSupressAllWarnings] = setup_window(...
        params.screen, 22  , params.debug_mode);
    
    % center the image as long as not debugging.
    if ~params.debug_mode    
        [width, height] = WindowSize(window);
        params.img_offset_x = floor(width / 2);
        params.img_offset_y = floor(height / 2);
    end
    
    % background index
    bkgd_lum = 18;
    bkgd = GrayIndex(window, bkgd_lum);
    bkgd = chrom_to_projector_RGB(cal, [0.310, 0.316, bkgd_lum], 'xyY');
    
    % display blank screen
    display_blank_screen(window, bkgd);

    % wait for user to advance
    KbWait(-1);
    
    % make sure there are no stickey key presses.
    pause(0.2); 
    
    % start the experiment
    for t = 1:params.ntrials
        % indicate start of trial
        sound(sin(1:100), 10000)
        pause(0.5);
        
        trial_params = params.stim_params(params.trial_ind(t), :);
        
        % get the xyY value for the trial
        x = trial_params(5);
        y = trial_params(6);
        
        xyY = [x y bkgd_lum];
        
        % rgb value of stimulus
        rgb = chrom_to_projector_RGB(cal, xyY, 'xyY');

        % display image
        display_image(window, bkgd, params, rgb);

        % flash duration
        pause(params.flash_duration);
        
        % display blank screen
        display_blank_screen(window, bkgd);
        
        % get user response
        response = get_key_input(params);

        % fill in response to data
        data(t, 1:6) = trial_params;
        data(t, 7:11) = response;
        
        % inform the subject that the responses were collected
        sound(sin(1:100), 50000);
        
        % wait until the subject initiates the next trial with space bar.
        out = get_key_input(params, 'spacebar');
        if strcmp(out, 'end')
            break
        end

    end
    
    cleanup(oldVisualDebugLevel, oldSupressAllWarnings);
catch  %#ok<*CTCH>
   
	cleanup();

	% We throw the error again so the user sees the error description.
	psychrethrow(psychlasterror);
    
end

save(['dat/' params.subject_id '_' date], 'data')