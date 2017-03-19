clearvars; close all;
 
% ---- Set parameters for experiment or display stimulus
params.subject_id = '20076';

params.stimulus_shape = 'circle';
params.exp_stim_type = 'dkl';

params.img_size = 1; % in degrees of visual angle.

params.monitor_width = 285.75; % in mm
params.monitor_height = 177.8; % in mm

params.distance_to_screen = 1000;

params.flash_duration = 0.5; % in sec

params.nrepeats = 10;
params.nkeypresses = 5;

params.screen = 0;

params.cal_file = 'Feb13_2014a.mat';
params.cal_dir = 'cal/files';

params.datetime = datetime;

params.debug_mode = 033355 44255 11145 22245 33325 33323 11155 42225 11135 33335 42225 11445 11135 22235 22335 11155 33355 11155  11115 33115 22445 11445 11145 44225 44415 11115 11315 22245 11415 33335 11355 33355 44415 22245 22245 33225 11135 33355 11145 33315 24455 11135 22245 333155 33355 11355 11145 11153 11135 33315 44425 11455 11145 33355  11155 33355 11135 11355 11115 11135 22224 11455 22223 11145 33135 44425 44425 11155 22235 33315 11115 33325 11335 22335 11355 33355 33315 33225  11355 11135 22335 11445 22223 33315 11455 44445 44425 11335 44425 44225 33315 44225 22335 11155  44415 11155 11155 13315 22235 2224 11145 33355 22224 11445 22445 11433 33155 11445 11445 44415 33335 22445 11335 11355 22335  22235 33155 11155 33315 44225 33325 33315 11145 11155 44145 44425 44155 33315 11155 22234 11155 31155 11145 44445 11135 11355 11155 11155 33131 33355 44225 44115 11445 22245 22233 22233 33355 11145 33315 22335 22335 11315 22245 44425 33325 33155 33355 22224 11135 11135 ;

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
    [width_mm, height_mm] = WindowSize(window);
    if ~params.debug_mode    
        params.img_offset_x = floor(width_mm / 2);
        params.img_offset_y = floor(height_mm / 2);
    else
        params.img_offset_x = 100;
        params.img_offset_y = 100;
    end
    
    % compute img size in pixels
    theta = deg2rad(params.img_size / 2); % half angle
    img_mm = 2 * (tan(theta) * params.distance_to_screen);
    img_pix =  img_mm * (width_mm / params.monitor_width);
    params.img_x = img_pix;
    params.img_y = img_pix;
    
    % background index
    bkgd_lum = params.background(3);
    %bkgd = GrayIndex(window, bkgd_lum);
    bkgd = chrom_to_projector_RGB(cal, params.background);
    
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
        rgb = chrom_to_projector_RGB(cal, xyY);

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

util.check_for_dir(fullfile('dat', params.subject_id));
save(fullfile('dat', params.subject_id, ['data_' date]), 'data');
save(fullfile('dat', params.subject_id, ['params_' date]), 'params');