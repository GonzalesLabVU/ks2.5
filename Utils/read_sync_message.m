function start_time_sample = read_sync_message(sync_message_dir)
fid = fopen(fullfile(sync_message_dir.folder, sync_message_dir.name));
all_text = char(fread(fid))';
fclose(fid);
start_time_text = regexp(all_text, 'start time: \d*', 'match');
if ~isempty(start_time_text)
start_time_sample = textscan(start_time_text{1}, 'start time: %d64');
start_time_sample = start_time_sample{1};
else
    start_time_sample = [];
end
end