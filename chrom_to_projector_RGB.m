function color = chrom_to_projector_RGB(cal, xyY)
    
    % Convert to RGB:
    XYZ = xyYToXYZ(xyY');
    [RGB, outOfRangePixels] = SensorToSettings(cal, XYZ);
    
    % Check for out-of-range non-displayable color values:
    if any(outOfRangePixels)
        fprintf('WARNING: Out of range RGB values!\n');
        fprintf('pix = %f\n', outOfRangePixels);
        fprintf('rgb = %f\n', RGB);
    end

    color = RGB * 255;
        
end

