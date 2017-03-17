function display_image(window, background, params, rgb)
    import white.*
    
    % ---------- Image Display ---------- 
    % 1. Colors the entire window gray.
    Screen('FillRect', window, background);
    
    % 2. Create stimulus
    rect = [0, 0, params.img_x, params.img_y];
    rect = CenterRectOnPoint(rect, params.img_offset_x, ...
        params.img_offset_y);
    
    
    % 3. Add stimulus to screen
    if strcmp(params.stimulus_shape, 'circle')
        Screen('FillOval', window, rgb, rect);

    elseif strcmp(params.stimulus_shape, 'rectangle')  
        Screen('FillRect', window, rgb, rect);
    end

    % 4. Updates the screen to reflect our changes to the window.
    Screen('Flip', window);
        
end