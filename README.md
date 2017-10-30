# CRT hue scaling

The main program is hue_scaling.m

## Instructions

Run hue_scaling.m

To advance to next trial press space bar.

After each flash indicate the hue and saturation of the spot with five button presses. Each button press can be either red (1), green (2), blue (3), yellow (4) or white (5). For example, a purely red spot would be 11111. A desaturated orange spot would be 14555.

The program is currently set to test 8 hue angles each at three different purity (saturation) levels. 

###Parameters to edit:

1. subject_id - for saving data
2. img_size - in degrees of visual angle
3. monitor_width[heigh] - size and width of screen in mm for computing image size.
4. distance_to_screen - distance of the subjct to the screen
5. flash duration. AOSLO experiments are typically run at 0.5 sec.
6. nrepeats - will change the number of times each color is presented.
7. nkeypresses - controls how many button presses are required in hue scaling
8. cal_file - to change the cal_file, copy new cal file into cal/files directory.