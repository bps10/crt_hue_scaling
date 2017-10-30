function response = get_key_input(params, input_type)
    if nargin < 2
        input_type = 'response';
    end

    if strcmpi(input_type, 'response')
        response = zeros(params.nkeypresses, 1);
        keyN = 1;
        while keyN <= params.nkeypresses

            % get the response
            [~, keycode, ~] = KbWait(-1);
            keyname = KbName(keycode);

            if strcmp(keyname(1), '1') 
                response(keyN) = 1;
                keyN = keyN + 1;
            elseif strcmp(keyname(1), '2')
                response(keyN) = 2;
                keyN = keyN + 1;
            elseif strcmp(keyname(1), '3')
                response(keyN) = 3;
                keyN = keyN + 1;            
            elseif strcmp(keyname(1), '4')
                response(keyN) = 4;
                keyN = keyN + 1;
            elseif strcmp(keyname(1), '5')
                response(keyN) = 5;
                keyN = keyN + 1;

            elseif strcmpi(keyname, 'escape')
                % ---------- Exit program if 'escape' key is pressed.
                cleanup();
                keyN = params.nkeypresses + 1;
                response = 'end';
                break

            end
            pause(0.2);

        end
    elseif strcmpi(input_type, 'spacebar')
        % wait until the space bar is pressed
        response = 'continue';
        pressed = false;
        while ~pressed
            
            % get the response
            [~, keycode, ~] = KbWait(-1);
            keyname = KbName(keycode);
            if strcmp(keyname, 'space') 
                pressed = true;
                
            elseif strcmpi(keyname, 'escape')
                % ---------- Exit program if 'escape' key is pressed.
                cleanup();
                pressed = true;  
                response = 'end';

            end            
        end
        pause(0.2);
    end
end