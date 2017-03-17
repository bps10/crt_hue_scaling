
% ------- Calibrate monitor -------------

% Supress checking behavior
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    
% Find out how many screens and use largest screen number.
whichScreen = max(Screen('Screens'));
% Hides the mouse cursor
HideCursor;

% Opens a graphics window on the main monitor (screen 0).
window = Screen('OpenWindow', whichScreen);


% ------ Gamma correction measurement ---------
numMeasures = 17; % should be 1 + power of 2 (9, 17, 33, ...)

input(sprintf(['When black screen appears, point photometer, \n' ...
       'get reading in cd/m^2, save to file, press enter. \n' ...
       'A screen of higher luminance will be shown. Repeat %d times. ' ...
       'Press enter to start'], numMeasures));

psychlasterror('reset');    
try
    screenid = max(Screen('Screens'));

    % Open black window:
    win = Screen('OpenWindow', screenid, 0);
    maxLevel = Screen('ColorRange', win);

    % Load identity gamma table for calibration:
    LoadIdentityClut(win);

    inputV = [0:(maxLevel + 1) / (numMeasures - 1):(maxLevel+1)]; %#ok<NBRAK>
    inputV(end) = maxLevel;
    
    j = 0;
    for i = inputV
        j = j + 1;
        Screen('FillRect',win, [i 0 0]);
        Screen('Flip',win);
        fprintf(['trial: ' num2str(j) 'RGB: ' num2str([i 0 0])]);
        resp = GetNumber;
    end

    j = 0;
    for i = inputV
        j = j + 1;
        Screen('FillRect',win, [0 i 0]);
        Screen('Flip',win);
        fprintf(['trial: ' num2str(j) 'RGB: ' num2str([0 i 0])]);
        resp = GetNumber;
    end

    j = 0;
    for i = inputV
        j = j + 1;
        Screen('FillRect',win, [0 0 i]);
        Screen('Flip',win);
        fprintf(['trial: ' num2str(j) 'RGB: ' num2str([0 0 i])]);
        resp = GetNumber;
    end
    
    % Restore normal gamma table and close down:
    RestoreCluts;
    Screen('CloseAll');
catch %#ok<*CTCH>
    RestoreCluts;
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end
