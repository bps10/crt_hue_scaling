function cal = cal_struct(cal_file, cal_dir)
    
    try
        %if exist(cal_file, 'file') == 2 && ...
        %        exist(cal_dir, 'dir') == 2
        cal = LoadCalFile(cal_file, [], cal_dir);
        %else
            % write something to get user input in the case that
            % the cal file doesn't exist
            %stim.cleanup();
            %error('Cal file does not exist.');
        %end

    catch
        stim.cleanup();
        error('Cal file not found.')
    end

    % use JuddVos xyz vals
    %[T_xyz, S_xyz] = cie1931CMFs();
    load T_xyzJuddVos
    T_xyzJuddVos = 683 .* T_xyzJuddVos;
    cal = SetSensorColorSpace(cal, T_xyzJuddVos, S_xyzJuddVos);
    cal = SetGammaMethod(cal, 0);

end