function AllData = add_spikes_sparse(AllData, sp, oe, task_counter)
%   Decode task type in behavior data
[~, ~, align_event_order_in_queue] = detect_task_type(AllData);
%   CONVERTS DATA MATRIX IDX TO TIMESTAMP!
ss                          = oe.continuous_timestamp(sp.ss);    % "ss" is MATLAB-generated and thus assumed to use 1-indexing
photodiode_time_event       = oe.photodiode_time_event;
fs_raw                      = sp.sample_rate;
clu                         = sp.clu;
n_cids                      = numel(sp.cids);
%
bound_dur  = get_task_trial_bound(AllData);
n_inbound_samples  = bound_dur * fs_raw;
trial_time_event_in_session = get_event_in_boundary(oe.session_time_event(task_counter, :), oe.trial_time_event);
trials = AllData.trials;
parfor i = 1:numel(trials)
    trial_time_event_in_trial      = trial_time_event_in_session(i, :);
    photodiode_time_event_in_trial = get_event_in_boundary(trial_time_event_in_trial, photodiode_time_event);
    if ~isempty(photodiode_time_event_in_trial)
%         [ss_in_trial, s_idx_in_trial]     = get_event_in_boundary(trial_time_event_in_trial, ss);
        [ss_in_bound, s_idx_in_bound]     = get_event_in_boundary(photodiode_time_event_in_trial(1) + int64(n_inbound_samples .* [-1, 1] + [0, -1]), ss);
        %   Align ss to photodiode event
        ss_offset                         = photodiode_time_event_in_trial(1) - n_inbound_samples(1) - 1;
        trials(i).ss                      = sparse(ss_in_bound - ss_offset, int64(clu(s_idx_in_bound)), true(size(ss_in_bound)), sum(n_inbound_samples), n_cids);
%         trials(i).ss                      = sparse(ss_in_trial - ss_offset, int64(clu(s_idx_in_trial)), true(size(ss_in_trial)), sum(n_inbound_samples), n_cids);
        trials(i).trial_on_event          = trial_time_event_in_trial(1) - ss_offset;
        trials(i).photodiode_on_event     = photodiode_time_event_in_trial(1) - ss_offset;
        %   Shift Psychtoolbox-generated timestamps by aligning cpu_trial_photodiode_latency w/ real_trial_to_photodiode_latency
        real_trial_to_photodiode_latency  = double(photodiode_time_event_in_trial(1) - trial_time_event_in_trial(1))/fs_raw;
        cpu_trial_to_photodiode_latency   = trials(i).timestamp_queue(align_event_order_in_queue) - trials(i).time;
        trials(i).timestamp_queue = trials(i).timestamp_queue + (real_trial_to_photodiode_latency - cpu_trial_to_photodiode_latency);
    else %  Trial contains no information if photodiode was not on
        trials(i).ss                      = logical(sparse([]));
        trials(i).trial_on_event          = [];
        trials(i).photodiode_on_event     = [];
    end
end
AllData.trials = trials;
fprintf('Spikes assigned.\n');
end
%%
function [event_in_boundary, event_sample] = get_event_in_boundary(boundary_event, base_event)
event_idx = and(base_event(:, 1) >= boundary_event(1), base_event(:, end) <= boundary_event(2));
event_in_boundary = base_event(event_idx, :);
event_sample = find(event_idx);
end