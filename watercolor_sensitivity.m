clearvars; close all;
 
% ---- Set parameters for experiment or display stimulus
params.subject_id = '20076';

params.watercolor_present = true;

params.stimulus_shape = 'circle'; % circle or square
params.exp_stim_type = 'watercolor'; % 

params.img_size = 0.25; % in degrees   of visual angle.

params.monitor_width = 285.75; % in mm
params.monitor_height = 177.8; % in mm

params.distance_to_screen = 1000;

params.flash_duration = 0.25; % in sec

params.nrepeats = 3; % number of times each color will be repeated
params.nkeypresses = 1; % number of hue scaling button presses (use 5).

params.screen = 0;
 
params.cal_file = 'planar_monitor_test.mat'; % 'Feb13_2014a.mat'
params.cal_dir = fullfile('cal', 'files');

params.debug_mode = 0;

params.datetime = datestr(datetime, 'ddmmmmyyyyHH:MM:SSAM');

% ---- Load calibration file:
cal = cal_struct(params.cal_file, params.cal_dir);

% get hue specific parameters
params.purity_vals = [0.4 0.6 1];
params = hue_scaling_params(params, cal);

data = zeros(params.ntrials, 8);

% load water color image
if params.watercolor_present 
    %watercolor = imread('./stim/PinnaScholarpedia_401px-Watercolor4_gray_bkgd.png');
    watercolor = imread('./stim/watercolor_v1.png');
else
    watercolor = imread('./stim/watercolor_v1control.png');
end

try
    % ---- Set up window
    [window, oldVisualDebugLevel, oldSupressAllWarnings] = setup_window(...
        params.screen, 22  , params.debug_mode);
    
    % if you want a blank screen, uncomment below
    % textureIndex = [];

    % center the image as long as not debugging.
    [width_mm, height_mm] = WindowSize(window);
    if ~params.debug_mode    
        params.img_offset_x = floor(width_mm / 2);
        params.img_offset_y = floor(height_mm / 2);
    else
        params.img_offset_x = 100;
        params.img_offset_y = 100;
    end
    HideCursor(params.screen, 0);
    
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
    
    % set background to black
    bkgd = [0 0 0];
    
    % display blank screen
    display_blank_screen(window, bkgd, textureIndex);

    % wait for user to advance
    KbWait(-1);
    
    % make sure there are no stickey key presses.
    pause(0.2); 
    
    % start the experiment
    for t = 1:params.ntrials
        % indicate start of trial
        sound(sin(1:100), 10000)
        pause(0.15);
        
        trial_params = params.stim_params(params.trial_ind(t), :);
        
        % get the xyY value for the trial
        x = trial_params(6);
        y = trial_params(7);
        
        xyY = [x y bkgd_lum];
        
        % rgb value of stimulus
        rgb = chrom_to_projector_RGB(cal, xyY);

        % display image
        display_image(window, bkgd, params, rgb, textureIndex);

        % flash duration
        pause(params.flash_duration);
        
        % display blank screen
        display_blank_screen(window, bkgd, textureIndex);
        
        % get user response
        response = get_key_input(params);
        if isstr(response)
            if strcmpi(response, 'end')
                break
            end
        end

        % fill in response to data
        data(t, 1:7) = trial_params;
        data(t, 8) = response;        
        
        % wait until the subject initiates the next trial with space bar.
        out = get_key_input(params, 'spacebar');
        if strcmpi(out, 'end')
            break
        end      
        
        pause(0.25);
        % inform the subject that the responses were collected
        sound(cos(1:1000), 15000);        
        pause(0.25);
        
        % give the subject time to rest half way through
        

    end
    
    cleanup(oldVisualDebugLevel, oldSupressAllWarnings);
catch  %#ok<*CTCH>
   
	cleanup();

	% We throw the error again so the user sees the error description.
	psychrethrow(psychlasterror);
    
end

util.check_for_dir(fullfile('dat', params.subject_id));
t = params.datetime;
save(fullfile('dat', params.subject_id, ['data_' t]), 'data');
save(fullfile('dat', params.subject_id, ['params_' t]), 'params');

plot_stimuli(params, cal);

plot_watercolor_data(params, data)
