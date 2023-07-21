function sp_new = zw_merge_clusters(sp, fr_treshold)
% ZW_MERGE_CLUSTERS takes the raw kilosort 2.5 output, compute an
% adjancency matrix for cluster pairs, merge clusters, recompute cluster
% parameters, weed out low firing clusters and re-index for output.
%%  Load data
sp = zw_templatePositionsAmplitudes(sp);
sp = compute_cluster_metrics(sp);
%%  Compute adjancency matrix
%   ACG similarity
sp.acg_corr_matrix = compute_acg_corr(sp);
%   Estimated source distance
sp.distance_matrix = compute_xy_distance(sp);
%   Waveform similarity
sp.adj_matrix      = (sp.similar_clusters >= 0.8) .* (sp.acg_corr_matrix >= 0.9) .* (abs(sp.distance_matrix) <= 50);
%   Amplitude-time overlap
sp.adj_matrix      = and_amplitude_overlap_matrix(sp, sp.adj_matrix, 0.6);
cids_idx_unmerged      = conncomp(graph(sp.adj_matrix), 'OutputForm', 'vector');
cids_unmerged = sp.cids(cids_idx_unmerged);
%%  Intermediate reassignment of clusters
sp_int = merge_cids(sp, cids_unmerged);
%%  Compute intermediate firing rate and remove low-firing clusters
sp_int        = compute_fr(sp_int);
cids_to_remove = sp.cids(or(logical(sp_int.fr < fr_treshold), logical(sp_int.fr_overall < fr_treshold/4)));
clear sp_int
cids_unmerged(ismember(cids_unmerged, cids_to_remove)) = -1; %   Dummy code for unwanted clusters in the raw cluster list
sp_new        = merge_cids(sp, cids_unmerged);
%%  Recompute cluster amplitude and location
%   Weighted averaging of merged cluster amplitude over channels
% for i = 1:numel(sp_new.cids)
%     to_merge = find(cids_unmerged == sp_new.cids(i));
%     if numel(to_merge) > 1
%         %   Weighted averages of channel amplitude and location for merged
%         %   clusters. Template projections cannot be easily recomputed.
%         %   Averaging templates and waveforms for a qualitative
%         %   representation. Actual spike waveforms should be extracted
%         %   using getWaveForms.m for analysis.
%         sp_new.clusterChanAmps_full(i, :) = sum(bsxfun(@times, sp.tempChanAmps_full(to_merge, :), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
%         sp_new.clusterYs(i)               = sum(bsxfun(@times, sp.templateYs(to_merge), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
%         sp_new.clusterXs(i)               = sum(bsxfun(@times, sp.templateXs(to_merge), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
%         sp_new.cluster_waveforms(i, :)    = sum(bsxfun(@times, sp.waveforms(to_merge, :), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
%         sp_new.cluster_temps(i, :, :)     = sum(bsxfun(@times, sp.temps(to_merge, :, :), (sp.n_st(to_merge) .* sp.clusterTempScalingAmps(to_merge))))/sum(sp.n_st(to_merge) .* sp.clusterTempScalingAmps(to_merge));
%         sp_new.cluster_tempAmps(i)        = sum(bsxfun(@times, sp.tempAmps(to_merge), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
%         sp_new.clusterTempScalingAmps(i)  = sum(bsxfun(@times, sp.clusterTempScalingAmps(to_merge), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
%     else %  Re-indexing of unchanged clusters
%         sp_new.clusterChanAmps_full(i, :) = sp.tempChanAmps_full(to_merge, :);
%         sp_new.clusterYs(i)               = sp.templateYs(to_merge);
%         sp_new.clusterXs(i)               = sp.templateXs(to_merge);
%         sp_new.cluster_waveforms(i, :)    = sp.waveforms(to_merge, :);
%         sp_new.cluster_temps(i, :, :)     = sp.temps(to_merge, :, :);
%         sp_new.cluster_tempAmps(i)        = sp.tempAmps(to_merge);
%     end
%     if sp_new.cids(i) < 0
%         sp_new.cgs(i)                  = 0; % Noise
%         if isfield(sp, 'ks_label')
%             sp_new.ks_label(i)         = 0;
%         end
%     else
%         % Take the mean when all labels non-zeros. When a cluster is
%         % similar to a noise cluster, deem both to be noises.
%         sp_new.cgs(i)                  = nonzero_mean(sp.cgs(to_merge)) * all(sp.cgs(to_merge));
%         if isfield(sp, 'ks_label')
%             sp_new.ks_label(i)         = nonzero_mean(sp.ks_label(to_merge)) * all(sp.ks_label(to_merge));
%         end
%     end
% end
%%  Reassign natural cids
% natural_cids = 1:numel(sp_new.cids);
% sp_natural   = merge_cids(sp_new, natural_cids);
% sp_new.cids  = sp_natural.cids;
% sp_new.clu   = sp_natural.clu;
%%  Re-populate parameters
sp_new = compute_cluster_metrics(sp_new);
sp_new = update_struct_new_field(sp_new, sp);
fprintf(1, 'Clusters merged.\n')
end
%%
function sp = merge_cids(sp, cids_unmerged)
sp.cids = unique(cids_unmerged); % @unique sorts small-to-large by default
to_assign = ismember_locb(sp.clu, sp.cids);
sp.clu(logical(to_assign))  = sp.cids(to_assign(logical(to_assign)));
sp.cids = sp.cids(sp.cids > -1); % Stop updating removed clusters
end
%%
function out = nonzero_mean(in)
out = mean(in(find(in)));
end