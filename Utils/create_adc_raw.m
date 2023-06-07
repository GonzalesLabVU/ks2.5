function create_adc_raw(sessions, raw_adc_dir)
for i_session = 1:numel(sessions)
    session_name = sessions(i_session).daq_folder.name(1:6);
    save_file    = fullfile(raw_adc_dir, [session_name, '_adc_event.mat']);
    if isfile(save_file)
        fprintf(1, '%s already exists.\n', save_file)
    else
        fprintf(1, 'Start binary2events on %s.\n', session_name);
        binary2events(fullfile(sessions(i_session).daq_files.oebin_file.folder, sessions(i_session).daq_files.oebin_file.name), save_file);
    end
end