function sessions = find_oe_beh_files(beh_dir, daq_dir, subject_identifier_cell, session_range)
%FIND_OE_BEH_FILES locates the OpenEphys file name expected for OE GUI
%version 0.5.X
%   Expected subfolder naming conventions
newer_version = '0.6.0';
daq_parent_folder = '\\Record Node*\\experiment*\\recording*\\';
daq_event_folder = '\\Record Node*\\experiment*\\recording*\\events\\Rhythm_FPGA-100.0\\TTL_1\\';
daq_continous_folder = '\\Record Node*\\experiment*\\recording*\\continuous\\Rhythm_FPGA-100.0\\';
if isempty(session_range)
    session_range = 1:1000;
end
session_counter = 0;
for i_subject = 1:numel(subject_identifier_cell)
    subject_identifier = subject_identifier_cell{i_subject};
    for i = 1:numel(session_range)
        session_identifier = [subject_identifier, sprintf('%03d', session_range(i))];
        daq_folder = dir(fullfile(daq_dir, ['*', session_identifier, '*']));
        if ~isempty(daq_folder)
            session_counter = session_counter + 1;
            sessions(session_counter).subject_identifier     = subject_identifier;
            sessions(session_counter).session_number         = session_range(i);
            sessions(session_counter).beh_files              = dir(fullfile(beh_dir, ['*', subject_identifier, sprintf('%03d', session_range(i)), '*']));
            sessions(session_counter).daq_folder             = daq_folder;
            recording_folder = fullfile(sessions(session_counter).daq_folder.folder, sessions(session_counter).daq_folder.name, daq_parent_folder);
            sessions(session_counter).daq_files.oebin_file   = dir(fullfile(recording_folder, '*oebin'));
            sessions(session_counter).daq_files.sync_message = dir(fullfile(recording_folder, '*sync_messages*'));
            oe_info = jsondecode(fileread(fullfile(sessions(session_counter).daq_files.oebin_file.folder, sessions(session_counter).daq_files.oebin_file.name)));
            daq_continous_folder = fullfile('continuous', oe_info.continuous.folder_name);
            ttl_events           = cellfun(@(x) ~isempty(regexpi(x.channel_name, 'fpga', 'once')), oe_info.events);
            daq_event_folder     = fullfile('events', oe_info.events{ttl_events}.folder_name);
            if at_least_version(newer_version, oe_info.GUIVersion)
                sessions(session_counter).daq_files.continuous_file         = dir(fullfile(recording_folder, daq_continous_folder, 'continuous.dat'));
                sessions(session_counter).daq_files.synchronized_file       = dir(fullfile(recording_folder, daq_continous_folder, 'timestamps.npy'));
                sessions(session_counter).daq_files.timestamps_file         = dir(fullfile(recording_folder, daq_continous_folder, 'sample_numbers.npy'));
                sessions(session_counter).daq_files.channel_states_file     = dir(fullfile(recording_folder, daq_event_folder, 'states.npy'));
                sessions(session_counter).daq_files.channel_timestamps_file = dir(fullfile(recording_folder, daq_event_folder, 'sample_numbers.npy'));
            else
                sessions(session_counter).daq_files.continuous_file         = dir(fullfile(recording_folder, daq_continous_folder, 'continuous.dat'));
                sessions(session_counter).daq_files.synchronized_file       = dir(fullfile(recording_folder, daq_continous_folder, 'synchronized_timestamps.npy'));
                sessions(session_counter).daq_files.timestamps_file         = dir(fullfile(recording_folder, daq_continous_folder, 'timestamps.npy'));
                sessions(session_counter).daq_files.channel_states_file     = dir(fullfile(recording_folder, daq_event_folder, 'channel_states.npy'));
                sessions(session_counter).daq_files.channel_timestamps_file = dir(fullfile(recording_folder, daq_event_folder, 'timestamps.npy'));                
            end
        end
    end
end
sessions = get_beh_info(sessions);
end