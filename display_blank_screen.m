function display_blank_screen(window, background, texturePointer)   
    % Show black screen in between stim presentations
    
    if nargin < 3
        texturePointer = [];
    end
    
    % ---------- Image Display ---------- 
    % 1. Colors the entire window gray.
    Screen('FillRect', window, background);
    
    if ~isempty(texturePointer)
        Screen('DrawTexture', window, texturePointer);
    end
    
    Screen('Flip', window);
    
end