function sessions = get_beh_info(sessions)
retrieve_counter = 0;
for i = 1:numel(sessions)
    start_times = zeros(1, numel(sessions(i).beh_files));
    beh_suffix  = zeros(1, numel(sessions(i).beh_files));
    for j = 1:numel(sessions(i).beh_files)
        load(fullfile(sessions(i).beh_files(j).folder, sessions(i).beh_files(j).name));
        start_times(j) = AllData.starttime;
        [~, fname] = fileparts(sessions(i).beh_files(j).name);
        fname_splits = strsplit(fname, '_');
        suffix = str2num(fname_splits{2});
        if isempty(suffix)
            beh_suffix(j) = 0;
        else
            beh_suffix(j) = suffix;
        end
    end
    sessions(i).beh_suffix = beh_suffix;
    [~, sessions(i).beh_order] = sort(start_times);
    if ~isempty(j)
        retrieve_counter = retrieve_counter + 1;
        fprintf('Retrieved behavior info from %d/%d sessions.\n', retrieve_counter, numel(sessions));
    else
        fprintf('Missing behavior info from %d/%d sessions.\n', i - retrieve_counter, numel(sessions));
    end
end