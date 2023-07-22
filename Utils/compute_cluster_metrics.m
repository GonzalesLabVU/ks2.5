function sp_new = compute_cluster_metrics(sp)
%   Use spikeTemplates to compute weighted averages of spatiotemporal
%   metrics for each cluster
sp = compute_fr(sp);
sp_new = sp;
sp_new.similar_clusters = zeros(numel(sp.cids), numel(sp.cids));
template_idx_in_cluster_cell = cell(numel(sp.cids), 1);
for i = 1:numel(sp.cids)
    spikeTemplate_in_cluster = sp.spikeTemplates(sp.clu == sp.cids(i));
    template_in_cluster = unique(spikeTemplate_in_cluster); % Col vector
    template_idx_in_cluster = template_in_cluster + 1;
    template_idx_in_cluster_cell{i} = template_idx_in_cluster;
    template_in_cluster_n_st = zeros(size(template_in_cluster));
    for k = 1:numel(template_in_cluster)
        template_in_cluster_n_st(k) = sum(spikeTemplate_in_cluster == template_in_cluster(k));
    end
    sp_new.clusterChanAmps_full(i, :) = sum(bsxfun(@times, sp.tempChanAmps_full(template_idx_in_cluster, :), template_in_cluster_n_st), 1)/sum(template_in_cluster_n_st);
    sp_new.clusterYs(i)               = sum(bsxfun(@times, sp.templateYs(template_idx_in_cluster), template_in_cluster_n_st), 1)/sum(template_in_cluster_n_st);
    sp_new.clusterXs(i)               = sum(bsxfun(@times, sp.templateXs(template_idx_in_cluster), template_in_cluster_n_st), 1)/sum(template_in_cluster_n_st);
    sp_new.cluster_waveforms(i, :)    = sum(bsxfun(@times, sp.waveforms(template_idx_in_cluster, :), template_in_cluster_n_st), 1)/sum(template_in_cluster_n_st);
    sp_new.cluster_temps(i, :, :)     = sum(bsxfun(@times, sp.temps(template_idx_in_cluster, :, :), (template_in_cluster_n_st .* sp.clusterTempScalingAmps(template_idx_in_cluster))), 1)/sum(template_in_cluster_n_st .* sp.clusterTempScalingAmps(template_idx_in_cluster));
    sp_new.cluster_tempAmps(i)        = sum(bsxfun(@times, sp.tempAmps(template_idx_in_cluster), template_in_cluster_n_st), 1)/sum(template_in_cluster_n_st);
    sp_new.clusterTempScalingAmps(i)  = sum(bsxfun(@times, sp.clusterTempScalingAmps(template_idx_in_cluster), template_in_cluster_n_st), 1)/sum(template_in_cluster_n_st);
end
for i = 1:numel(sp.cids)
    for j = i:numel(sp.cids)
        sp_new.similar_clusters(i, j) = max(sp.similar_templates(template_idx_in_cluster_cell{i}, template_idx_in_cluster_cell{j}), [], 'all');
        sp_new.similar_clusters(j, i) = sp_new.similar_clusters(i, j);
    end
end
end