function create_sparse_neuron_from_ks(sessions, ks_working_directory, neuron_output_directory, varargin)
%%CREATE_NEURON_FROM_KS goes through the behavior files in each SESSIONS and
%%create neuron files from matching kilosort output
tic
%%  Specifies the KS option set of choice when potentially spike sorting was repeated with more than 1 set
i_ops_list = 0;
fr_threshold = 0.1;
if numel(varargin) > 0
    i_ops_list = varargin{1};
end
if numel(varargin) > 1
    fr_threshold = varargin{2};
end
%%
addpath(genpath('External')) % path to external functions
%%
cluster_info_directory = fullfile(neuron_output_directory, 'cluster_info');
if ~isfolder(cluster_info_directory)
    mkdir(cluster_info_directory);
end
%%
for i_session = 1:numel(sessions)
    session = sessions(i_session);
    %   Load OE data not used by Kilosort
    oe    = loadOE(session);
    %%  Load spikes
    ks_out_folder = fullfile(ks_working_directory, session.daq_folder.name, num2str(i_ops_list), 'kilosort3');
    sp = loadKSdir(ks_out_folder);
    sp = load_ks_extra(ks_out_folder, sp);
    sp = zw_merge_clusters(sp, fr_threshold);
    toc
    task_counter = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   Add spikes to AllData
            for i_beh = session.beh_order % Loop through chronologically ordered behavior files
                %   Rearrange behavior data
                clear AllData MatData
                %   Load AllData
                load(fullfile(session.beh_files(i_beh).folder, session.beh_files(i_beh).name), 'AllData');
                [task_type, state_code_threshold] = detect_task_type(AllData);
                if state_code_threshold < 0
                    %   Non-ephys files (e.g. calibration) dummy coded for exclusion
                    continue
                end
                task_counter = task_counter + 1;
                %   Temp AllData structure with spike time added
                AllData_c = add_spikes_sparse(AllData, sp, oe, task_counter);
                toc
                %
                AllData_c.trials = rmfield(AllData_c.trials, {'eye_time', 'eye_loc'});
                %   Give timestamp event names according to task type
                AllData_c.trials = verbose_timestamps(AllData_c.trials, task_type);
                %   Outputing
                %             current_cluster_group_ = find(ismember(cluster_groups, clusters(i_cluster).cluster_group));
                MatData            = gather_sp(AllData_c, sp);
                MatData.beh_file   = session.beh_files(i_beh).name;
                MatData.daq_folder = session.daq_folder.name;
                MatData.task_type  = task_type;
                MatData.state_code_threshold = state_code_threshold;
                save(fullfile(neuron_output_directory, sprintf('%s_sparse', session.beh_files(i_beh).name(1:end - 4))), 'MatData');
            end
        toc
end
end
%%
function MatData = gather_sp(AllData, sp)
MatData = AllData;
new_fieldnames = fieldnames(sp);
for i = 1:numel(new_fieldnames)
    if and(~isfield(AllData, new_fieldnames{i}), ismember(numel(sp.(new_fieldnames{i})) , [1, numel(sp.tempAmps), numel(sp.xcoords), numel(sp.cids)]))
        MatData.(new_fieldnames{i}) = sp.(new_fieldnames{i});
    end
end
end
%%