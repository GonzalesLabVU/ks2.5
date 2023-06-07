%%  Load additional information from Kilosort folder omitted by Spikes
function spikeStructure = load_ks_extra(ksDir, spikeStructure)
spikeStructure.ss                = readNPY(fullfile(ksDir, 'spike_times.npy'));
spikeStructure.similar_templates = readNPY(fullfile(ksDir, 'similar_templates.npy'));
end
