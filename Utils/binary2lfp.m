function binary2lfp_alt(oebin_file, save_file, varargin)
% Saman Abbaspoor - Feb 2021
% sabbaspoor.neusci@gmail.com
% This function converts continues files to
% downsampled filtered LFP of double precision.
% Analysis Tools from OpenEphys is required for this function to run.
% https://github.com/open-ephys/analysis-tools
% 
% Edited by Zhengyang Wang - Aug 2024
% Binary data is written time sample by tim 

tic
p = inputParser;
addParameter(p,'fs_LFP', 500, @isnumeric)
addParameter(p,'freq_hi', 250, @isnumeric)
addParameter(p,'n_filt', 3, @isinteger);
addParameter(p,'ram_use', 0.6, @isnumeric);
parse(p,varargin{:})

fs_LFP  = p.Results.fs_LFP;
freq_hi = p.Results.freq_hi;
n_filt  = p.Results.n_filt;
ram_use = p.Results.ram_use;
%%
save_dir = fileparts(save_file);
if ~isfolder(save_dir)
    mkdir(save_dir);
end
%% Load Data
D = loadData(oebin_file);
bitVolts = matlab_jsondecode_arrayfun_wrapper(@(x) x.bit_volts, D.Header.channels);
fs_raw = D.Header.sample_rate;
downsample_ratio = fs_raw/fs_LFP;
%% Filter Design
[b, a] = butter(n_filt, freq_hi/(fs_raw/2));
%% Fitlering and Downsampling
time_sample = downsample(D.Timestamps, fs_raw/fs_LFP);
% timestamps = timestamps(1:sampling_freq/1000:SampleNum);
n_chan = size(D.Data.Data.mapped, 1);
lfp_size = [n_chan, numel(time_sample)];
lfp = NaN(lfp_size);
byte_per_channel = D.Data.Format{2}(2) * get_dtype_byte(D.Data.Format{1});
[~, system_view] = memory;
total_ram  = system_view.PhysicalMemory.Total;

n_chan_per_block = floor((ram_use * total_ram) / byte_per_channel);
n_blocks = ceil(D.Data.Format{2}(1) / n_chan_per_block);
for block = 1:n_blocks
    chan_in_block = ((block - 1) * n_chan_per_block + 1):min(block * n_chan_per_block, n_chan);
    Data_in_block = D.Data.Data.mapped(chan_in_block, :);
    memory
    clear D
    D = loadData(oebin_file);
    memory
    for Channel = chan_in_block
        toc
        fprintf(1, 'Channel %d started... \n', Channel);
        Data = double(Data_in_block(Channel - (block - 1) * n_chan_per_block, :)) .* bitVolts(Channel);
        signal = filtfilt(b, a, Data);
        lfp(Channel, :) = downsample(signal, downsample_ratio);
    end
end
%%
lfp_structure.lfp         = lfp;
lfp_structure.time_sample = time_sample;
lfp_structure.oebin_file  = oebin_file;
lfp_structure.parameters  = p.Results;
%% Save
save(save_file, 'lfp_structure', '-v7.3');
toc
fprintf(1, 'Complete. MAT file saved to %s.\n', save_file);
end
function out = load_and_clear(D, slice)
out = D.Data.Data.mapped; %convert data to double precision
clear D
end



