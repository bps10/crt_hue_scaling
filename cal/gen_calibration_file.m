calibration_file_name = 'data/roorda_march12_2014_raw_data_EDIT.csv';
% Create calibration structure;
cal = [];

% Script parameters
cal.describe.nAverage = 2;  
cal.describe.nMeas = 16;
cal.nDevices = 3;
cal.nPrimaryBases = 1;
cal.describe.S = [380 1 401];
cal.manual.use = 1;

% Enter screen
cal.describe.whichScreen = 0;

% Find out about screen
cal.describe.dacsize = ScreenDacBits(0);
nLevels = 2 ^ cal.describe.dacsize;

cal.manual.photometer = 1;


% Prompt for background values.  The default is a guess as to what
% produces one-half of maximum output for a typical CRT.
defBgColor = [190 190 190]' / 255;
thePrompt = sprintf(...
'Enter RGB values for background (range 0-1) as a row vector [%0.3f %0.3f %0.3f]: ',...
                    defBgColor(1), defBgColor(2), defBgColor(3));
while 1
	cal.bgColor = input(thePrompt)';
	if isempty(cal.bgColor)
		cal.bgColor = defBgColor;
	end
	[m, n] = size(cal.bgColor);
	if m ~= 3 || n ~= 1
		fprintf(...
        '\nMust enter values as a row vector (in brackets).  Try again.\n');
    elseif (any(defBgColor > 1) || any(defBgColor < 0))
        fprintf('\nValues must be in range (0-1) inclusive.  Try again.\n');
    else
		break;
	end
end

% Get distance from meter to screen.
defDistance = .25;
theDataPrompt = sprintf(...
    'Enter distance from meter to screen (in meters): [%g]: ', defDistance);
cal.describe.meterDistance = input(theDataPrompt);
if isempty(cal.describe.meterDistance)
  cal.describe.meterDistance = defDistance;
end

% Fill in descriptive information
computerInfo = Screen('Computer');
hz = Screen('NominalFrameRate', cal.describe.whichScreen);
cal.describe.caltype = 'monitor';
if isfield(computerInfo, 'consoleUserName')
    cal.describe.computer = sprintf('%s''s %s, %s', ...
        computerInfo.consoleUserName, computerInfo.machineName, ...
        computerInfo.system);
else
    % Better than nothing:
    cal.describe.computer = OSName;
end
cal.describe.monitor = input('Enter monitor name: ','s');
cal.describe.driver = sprintf('%s %s','unknown_driver','unknown_driver_version');
cal.describe.hz = hz;
cal.describe.who = input('Enter your name: ','s');
cal.describe.date = sprintf('%s %s',date,datestr(now,14));
cal.describe.program = sprintf('calibration.m, background set to [%g,%g,%g]',...
                               cal.bgColor(1), cal.bgColor(2), cal.bgColor(3));
cal.describe.comment = input('Describe the calibration: ','s');


% Get name
defaultFileName = 'monitor';
thePrompt = sprintf('Enter calibration filename [%s]: ',defaultFileName);
newFileName = input(thePrompt,'s');
if isempty(newFileName)
    newFileName = defaultFileName;
end

% Fitting parameters
cal.describe.gamma.fitType = 'cubic interpolation';


cal_data = csvread(calibration_file_name);

% ---- Subtract off ambient light from each measurment
corrected_data = zeros(cal.describe.S(3), cal.describe.nMeas * 3);
ave_ambient = zeros(cal.describe.S(3), 1);
k = 1;
for i=0:2
    ambient_index = 2 + i * (cal.describe.nMeas + 1);
    ambient = cal_data(:, ambient_index);
    ave_ambient = ave_ambient + ambient;
    for j=1:cal.describe.nMeas
        ind = ambient_index + j;
        corrected_data(:, k) = cal_data(:, ind) - ambient;
        k = k + 1;
    end
end
% ---- fill in ambient parameters
ave_ambient = ave_ambient / cal.describe.nMeas;


corrected_data = reshape(corrected_data, ...
    cal.describe.S(3) * cal.describe.nMeas,cal.nDevices);

% Pre-process data to get rid of negative values.
corrected_data = EnforcePos(corrected_data);
cal.rawdata.mon = corrected_data;

% Use data to compute best spectra according to desired
% linear model.  We use SVD to find the best linear model,
% then scale to best approximate maximum
disp('Computing linear models');
cal = CalibrateFitLinMod(cal);

cal.P_ambient = ave_ambient;
cal.S_ambient = cal.S_device;
cal.T_ambient = eye(cal.describe.S(3));


% Fit gamma functions.

% Define input settings for the measurements
mGammaInputRaw = linspace(0, 1, cal.describe.nMeas+1)';
mGammaInputRaw = mGammaInputRaw(2:end);

cal.rawdata.rawGammaInput = mGammaInputRaw;

mGammaMassaged = cal.rawdata.rawGammaTable(:,1:cal.nDevices);
for i = 1:cal.nDevices
    mGammaMassaged(:,i) = MakeGammaMonotonic(HalfRect(mGammaMassaged(:,i)));
end

mGammaMassaged = NormalizeGamma(mGammaMassaged);
%cal = CalibrateFitGamma(cal, 2^cal.describe.dacsize);

%Gamma function fittings
nInputLevels = 1024;
gammaInputFit = linspace(0,1,nInputLevels)';
% append 0 at beginning so cubic fitting goes to 0
r_table = interp1([0 mGammaInputRaw']', [0 mGammaMassaged(:, 1)'], ...
    gammaInputFit, 'cubic');
g_table = interp1([0 mGammaInputRaw']', [0 mGammaMassaged(:, 2)']', ...
    gammaInputFit, 'cubic');
b_table = interp1([0 mGammaInputRaw']', [0 mGammaMassaged(:, 3)']', ...
    gammaInputFit, 'cubic');

cal.gammaInput = gammaInputFit;
cal.gammaTable = [r_table g_table b_table];

fprintf(1, '\nSaving to %s.mat\n', newFileName);
SaveCalFile(cal, newFileName);
    
plot_cal_data(cal);

