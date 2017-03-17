function color = chrom_to_projector_RGB(cal, chromaticity, color_space)
    if nargin < 3
        color_space = 'xyY';
    end

    a = chromaticity(1);
    b = chromaticity(2);
    LUM = chromaticity(3);
    
    % Convert to RGB:
    if strcmp(color_space, 'Luv')
        %Luv = [params.LUM x y]';
        xy = uvToxy([a b]');
        xyY = [xy(1), xy(2) LUM]';
        
    elseif strcmp(color_space, 'xyY')
        xyY = [a b LUM]'; 
    end
    
    XYZ = xyYToXYZ(xyY);
    [RGB, outOfRangePixels] = SensorToSettings(cal, XYZ);
    
    % Check for out-of-range non-displayable color values:
    if any(outOfRangePixels)
        fprintf('WARNING: Out of range RGB values!\n');
        fprintf('pix = %f\n', outOfRangePixels);
        fprintf('rgb = %f\n', RGB);
    end

    color = RGB * 255;
        
end

