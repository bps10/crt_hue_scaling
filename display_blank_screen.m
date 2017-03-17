function display_blank_screen(window, color)   
    % Show black screen in between stim presentations
    
    % ---------- Image Display ---------- 
    % 1. Colors the entire window gray.
    Screen('FillRect', window, color);
    Screen('Flip', window);
    
end