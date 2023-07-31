function neuron_table = sparse_to_single_mat(MatData_sparse, prev_neuron_count, neuron_table, neuron_output_dir)
MatData_sparse = stationarityCheck_wrapper(MatData_sparse);
if ~isfield(MatData_sparse, 'isi_violation')
    return
end
single_units = find(or(MatData_sparse.ks_label == 2, and((MatData_sparse.amp_rms >= 5), (MatData_sparse.isi_violation <= 1))));
neuron_idx   = prev_neuron_count + (1:numel(single_units));
sparse_trials_idx = find(ismember({MatData_sparse.trials.Reward}, 'Yes'));
sparse_trials = MatData_sparse.trials(sparse_trials_idx);
single_MatData_sparse = cell(size(single_units));
trial_field_names = fieldnames(MatData_sparse.trials);
T_fieldnames = trial_field_names(cellfun(@(x) contains(x, {'onT','inT','offT'}), trial_field_names));
align_T      = 'Cue_onT';
ntr_temp = struct();
for i_trial = 1:numel(sparse_trials)
    if isfield(sparse_trials, 'Cue_onT')
    for i_T = 1:numel(T_fieldnames)
        ntr_temp(i_trial).(T_fieldnames{i_T}) = sparse_trials(i_trial).(T_fieldnames{i_T}) - sparse_trials(i_trial).(align_T);
    end
    end
    ntr_temp(i_trial).Class = sparse_trials(i_trial).Class;
end
for i_su = 1:numel(single_units)
single_MatData_sparse{i_su} = ntr_temp;
for i_trial = 1:numel(sparse_trials)
single_MatData_sparse{i_su}(i_trial).TS = (find(sparse_trials(i_trial).ss(:, single_units(i_su))) - double(sparse_trials(i_trial).photodiode_on_event))'/MatData_sparse.sample_rate;
single_MatData_sparse{i_su}(i_trial).stationary = MatData_sparse.stationary(single_units(i_su), sparse_trials_idx(i_trial));
end
Filename  = MatData_sparse.beh_file(1:end-4);
save_name = sprintf('%s_%05.f', Filename, neuron_idx(i_su));
MatData = struct;
MatData.ntr = single_MatData_sparse{i_su};
new_row      = {Filename, neuron_idx(i_su), MatData_sparse.cluster_chan(single_units(i_su)), {MatData_sparse.cids(single_units(i_su))}};
neuron_table = [neuron_table; new_row];
save(fullfile(neuron_output_dir, save_name), 'MatData')
end
end