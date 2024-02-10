%%
function sparse_to_single_mat_batch(subject_identifier, sparse_neuron_output_folder, sua_output_folder, mua_output_folder)
neuron_table_file = fullfile(sua_output_folder, 'neuron_table.xls');
mua_table_file = fullfile(mua_output_folder, 'mua_table.xls');
neuron_table   = readtable(neuron_table_file);
mua_table   = readtable(mua_table_file);

for i_subject = 1:numel(subject_identifier)
    sparse_neurons = dir(fullfile(sparse_neuron_output_folder, ['*', subject_identifier{i_subject}, '*.mat']));
    session_number = arrayfun(@(x) str2num(x.name(4:6)), sparse_neurons);
    [~, session_order] = sort(session_number);
    sparse_neurons = sparse_neurons(session_order);
    session_number = session_number(session_order);
    subject_sua_output_folder = fullfile(sua_output_folder, subject_identifier{i_subject});
    subject_mua_output_folder = fullfile(mua_output_folder, subject_identifier{i_subject});
    if ~isfolder(subject_sua_output_folder)
        mkdir(subject_sua_output_folder)
    end
    if ~isfolder(subject_mua_output_folder)
        mkdir(subject_mua_output_folder)
    end

    for i_sparse = 1:numel(sparse_neurons)
        sparse_file_path = fullfile(sparse_neurons(i_sparse).folder, sparse_neurons(i_sparse).name);
        [neuron_table, mua_table] = sparse_to_single_mat(sparse_file_path, subject_identifier{i_subject}, session_number(i_sparse), neuron_table, mua_table, subject_sua_output_folder, subject_mua_output_folder);
        writetable(neuron_table, neuron_table_file, 'WriteRowNames',true, 'FileType','spreadsheet');
        writetable(mua_table, mua_table_file, 'WriteRowNames',true, 'FileType','spreadsheet');
        fprintf('%d of %d sessions with single mat generated for %d of %d subjects.\n', i_sparse, numel(sparse_neurons), i_subject, numel(subject_identifier));
    end
end
end
