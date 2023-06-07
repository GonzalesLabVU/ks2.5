function [onset_new, offset_new] = detect_analog_edge(data_in, fs, abs_threshold, gap_threshold_t)
%   Finds parts of analog signal that are modulated
abs_data_in    = abs(data_in);
raw_in         = abs_data_in > abs_threshold;
diff_raw_in    = diff(raw_in);
raw_onset      = find(diff_raw_in == 1);
raw_offset     = find(diff_raw_in == -1);
gap_threshold_sample = ceil(fs * gap_threshold_t);
[onset_new, offset_new] = fix_gap(raw_onset, raw_offset, gap_threshold_sample);

end
%%
function [onset_new, offset_new] = fix_gap(onset, offset, gap_threshold_sample)
event_gap     = onset(2:end) - offset(1:end - 1);
gap_to_delete = find(event_gap < gap_threshold_sample);
onset_new     = onset;
offset_new    = offset;
onset_new(gap_to_delete + 1) = [];
offset_new(gap_to_delete)    = [];
end