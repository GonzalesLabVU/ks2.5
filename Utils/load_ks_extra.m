%%  Load additional information from Kilosort folder omitted by Spikes
function spikeStructure = load_ks_extra(ksDir, spikeStructure)
spikeStructure.ss                = readNPY(fullfile(ksDir, 'spike_times.npy'));
spikeStructure.similar_templates = readNPY(fullfile(ksDir, 'similar_templates.npy'));
if exist(fullfile(ksDir, 'cluster_KSLabel.tsv'), 'file') 
        [cids_ks, ks_label]     = readClusterGroupsCSV(fullfile(ksDir, 'cluster_KSLabel.tsv'));
        cids_cgs                = spikeStructure.cids;
        cgs                     = spikeStructure.cgs;
        cids_u                  = union(cids_cgs, cids_ks);
        spikeStructure.ks_label = nan(size(cids_u));
        spikeStructure.cgs      = nan(size(cids_u));
        spikeStructure.ks_label(ismember_locb(cids_ks, cids_u)) = ks_label;
        spikeStructure.cgs(ismember_locb(cids_cgs, cids_u)) = cgs;
        spikeStructure.cids     = cids_u;
        assert(numel(cids_u) == size(spikeStructure.temps, 1), 'Cluster id mismatch in %s', ksDir);
end 

end
