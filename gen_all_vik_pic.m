clc
clear
fclose all;
zw_setpath;
%%  Subject to process
subject_identifier = {'VIK', 'PIC'};
subject_pattern = strjoin(subject_identifier, '|');
session_pattern = '\d{3}';
exp_pattern     = sprintf('(%s)%s', subject_pattern, session_pattern);
%%  
ks_dir  = 'Z:\Development_project_2019\VanderbiltDAQ\KS_out'; % Folder for storing sorted data
ks_output_dirs = multi_dir(fullfile(ks_dir, '*\*\*\kilosort3*'));
sp_dir  = 'C:\Database\VanderbiltDAQ\spike_structure'; % Folder for storing temp spike data structure
beh_dir = {'Z:\Development_project_2019\Neuropixels\beh', 'Z:\Development_project_2019\VanderbiltDAQ\beh\*'}; % Folder for behavior files
daq_dir = {'Z:\Development_project_2019\Neuropixels', 'Z:\Development_project_2019\VanderbiltDAQ\Open Ephys'}; % Folder for raw ephys data files
raw_lfp_dir = 'Z:\Development_project_2019\VanderbiltDAQ\raw_LFP'; % Folder where files like "VIK***_adc_event.mat" are stored
sparse_output_folder = 'C:\Database\VanderbiltDAQ\NeuronFiles';
sua_output_folder    = 'C:\Database\VanderbiltDAQ\single_neuron_files';
mua_output_folder    = 'C:\Database\VanderbiltDAQ\mua_files';
session_table = readtable('Z:\Development_project_2019\VanderbiltDAQ\Protocol_book_upload.xlsx', 'Sheet', 'session');
probe_table = readtable('Z:\Development_project_2019\VanderbiltDAQ\Protocol_book_upload.xlsx', 'Sheet', 'probe');
database2019_fname = 'Z:\Development_project_2019\VanderbiltDAQ\Database2019_copy\Dev_Project2019.accdb';
if isfile(database2019_fname)
    access_mdb = AccessDatabase_OLEDB(database2019_fname);
    wake_neuron_table = get_access_mdb_table(access_mdb,[],{'Neuron'});
end
%%  Convert Kilosort output to matlab records
create_sp_from_ks(ks_output_dirs, exp_pattern, sp_dir, 'do_assign_session_probe_info', true, 'session_table', session_table, 'probe_table', probe_table);
%%  Gather information from raw files   
session_ranges = [];
sessions = find_oe_beh_files(beh_dir, daq_dir, subject_identifier, session_ranges);
%%  Create sparse files
create_sparse_neuron_from_sp(sessions, sp_dir, sparse_output_folder, 'adc_input_directory', raw_lfp_dir, 'split_by_area', 0, 'stationary', 1);
%%  Create single mat files
neuron_table_file = fullfile(sua_output_folder, 'neuron_table.xls');
mua_table_file = fullfile(mua_output_folder, 'mua_table.xls');
if ~isfile(neuron_table_file)
    writetable(wake_neuron_table, neuron_table_file, 'WriteRowNames',true, 'FileType','spreadsheet')
end
if ~isfile(mua_table_file)
    writetable(wake_neuron_table([], :), mua_table_file, 'WriteRowNames',true, 'FileType','spreadsheet')
end
sparse_to_single_mat_batch(subject_identifier, sparse_output_folder, sua_output_folder, mua_output_folder)