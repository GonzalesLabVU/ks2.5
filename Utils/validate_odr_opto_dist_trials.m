function MatData = validate_odr_opto_dist_trials(MatData)
current_correct = ismember({MatData.trials.Reward}, 'Yes');
prev_correct    = [0, current_correct(1:end - 1)];
prev_class      = [0, [MatData.trials(1:end - 1).Class]];
current_fix     = [MatData.trials.Statecode] >= 3;
laser_delivered = cellfun(@(x) ~isempty(x), {MatData.trials.analog_on_event});
photodiode_on   = cellfun(@(x) ~isempty(x), {MatData.trials.photodiode_on_event});
helper_on       = cellfun(@(x) ~isempty(x), {MatData.trials.adc_helper_on_event});
valid_stim      = logical(laser_delivered);
valid_control   = logical(~laser_delivered);

MatData.current_correct = current_correct;
MatData.prev_class      = prev_class;
MatData.valid_stim      = valid_stim;
MatData.valid_control   = valid_control;
MatData.photodiode_on   = photodiode_on;
MatData.valid_lead      = false(size(valid_stim));
MatData.valid_lead(find(prev_correct) - 1) = true;

MatData.current_class = [MatData.trials.visual_angle_1];
MatData.trial_num     = 1:numel(MatData.trials);
mean_adc_helper_lag = mean([MatData.trials(laser_delivered).analog_on_event] - [MatData.trials(laser_delivered).adc_helper_on_event]);
for i = 1:numel(MatData.trials)
    if helper_on(i) && (~laser_delivered(i))
        MatData.trials(i).control_analog_on_event = MatData.trials(i).adc_helper_on_event + mean_adc_helper_lag;
    else
        MatData.trials(i).control_analog_on_event = int64([]);
    end
end
MatData.mean_analog_dur = mean(double([MatData.trials.analog_off_event] - [MatData.trials.analog_on_event]))/MatData.sample_rate;
MatData.mean_adc_helper_lag_t = double(mean_adc_helper_lag)/MatData.sample_rate;
%   Compute the minimum cue-free duration following analog_on_event or control_analog_on_event
trials_min_analog_photodiode_lag_t = photodiode_on & helper_on;
MatData.trials = merge_empty_struct_array_fields(MatData.trials, {'control_analog_on_event', 'analog_on_event'}, 'merge_analog_on_event');
MatData.min_analog_photodiode_lag_t = min(double([MatData.trials(trials_min_analog_photodiode_lag_t).photodiode_on_event] - [MatData.trials(trials_min_analog_photodiode_lag_t).merge_analog_on_event]))/MatData.sample_rate;
end