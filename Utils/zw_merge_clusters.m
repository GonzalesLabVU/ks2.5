function sp_new = zw_merge_clusters(sp, fr_treshold)
% ZW_MERGE_CLUSTERS takes the raw kilosort 2.5 output, compute an
% adjancency matrix for cluster pairs, merge clusters, recompute cluster
% parameters, weed out low firing clusters and re-index for output.
%%  Load data
sp = zw_templatePositionsAmplitudes(sp);
sp = compute_fr(sp);
%%  Compute adjancency matrix
%   ACG similarity
sp.acg_corr_matrix = compute_acg_corr(sp);
%   Estimated source distance
sp.distance_matrix = compute_xy_distance(sp);
%   Waveform similarity
sp.adj_matrix      = (sp.similar_templates >= 0.8) .* (sp.acg_corr_matrix >= 0.9) .* (abs(sp.distance_matrix) <= 50);
%   Amplitude-time overlap
sp.adj_matrix      = and_amplitude_overlap_matrix(sp, sp.adj_matrix, 0.6);
cids_unmerged      = conncomp(graph(sp.adj_matrix), 'OutputForm', 'vector') - 1; %   Inherit 0-indexing for consistency
%%  Intermediate reassignment of clusters
sp_int = merge_cids(sp, cids_unmerged);
%%  Compute intermediate firing rate and remove low-firing clusters
sp_int      = compute_fr(sp_int);
to_remove   = sp.cids(or(logical(sp_int.fr < fr_treshold), logical(sp_int.fr_overall < fr_treshold/4)));
clear sp_int
cids_unmerged(ismember(cids_unmerged, to_remove)) = -1; %   Dummy code for unwanted clusters in the raw cluster list
sp_new      = merge_cids(sp, cids_unmerged);
%%  Recompute cluster amplitude and location
%   Weighted averaging of merged cluster amplitude over channels
for i = 1:numel(sp_new.cids)
    to_merge = find(cids_unmerged == sp_new.cids(i));
    if numel(to_merge) > 1
        %   Weighted averages of channel amplitude and location for merged
        %   clusters. Template projections cannot be easily recomputed.
        %   Averaging templates and waveforms for a qualitative
        %   representation. Actual spike waveforms should be extracted
        %   using getWaveForms.m for analysis.
        sp_new.tempChanAmps_full(i, :)   = sum(bsxfun(@times, sp.tempChanAmps_full(to_merge, :), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
        sp_new.templateYs(i)             = sum(bsxfun(@times, sp.templateYs(to_merge), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
        sp_new.templateXs(i)             = sum(bsxfun(@times, sp.templateXs(to_merge), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
        sp_new.waveforms(i, :)           = sum(bsxfun(@times, sp.waveforms(to_merge, :), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
        sp_new.temps(i, :, :)            = sum(bsxfun(@times, sp.temps(to_merge, :, :), (sp.n_st(to_merge) .* sp.clusterTempScalingAmps(to_merge))))/sum(sp.n_st(to_merge) .* sp.clusterTempScalingAmps(to_merge));
        sp_new.tempAmps(i)               = sum(bsxfun(@times, sp.tempAmps(to_merge), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
        sp_new.clusterTempScalingAmps(i) = sum(bsxfun(@times, sp.clusterTempScalingAmps(to_merge), sp.n_st(to_merge)))/sum(sp.n_st(to_merge));
    else %  Re-indexing of unchanged clusters
        sp_new.tempChanAmps_full(i, :) = sp.tempChanAmps_full(to_merge, :);
        sp_new.templateYs(i)           = sp.templateYs(to_merge);
        sp_new.templateXs(i)           = sp.templateXs(to_merge);
        sp_new.waveforms(i, :)         = sp.waveforms(to_merge, :);
        sp_new.temps(i, :, :)          = sp.temps(to_merge, :, :);
        sp_new.tempAmps(i)             = sp.tempAmps(to_merge);
    end
    if sp_new.cids(i) < 0
        sp_new.cgs(i)                  = 0; % Unclustered
    else
        sp_new.cgs(i)                  = mean(sp.cgs(to_merge));
    end
end
%   Cluster depth based on amplitude center of mass
% templateDepths = compute_depth_from_channel_amplitude(tempChanAmps_full);
%%  Reassign natural cids
natural_cids = 1:numel(sp_new.cids);
sp_natural   = merge_cids(sp_new, natural_cids);
sp_new.cids  = sp_natural.cids;
sp_new.clu   = sp_natural.clu;
%%  Re-populate parameters
sp_new = compute_fr(sp_new);
sp_new = update_struct_new_field(sp_new, sp);
fprintf(1, 'Clusters merged.\n')
end
%%
function sp_new = merge_cids(sp, cids_unmerged)
sp_new.cids = unique(cids_unmerged); % @unique sorts small-to-large by default
sp_new.clu  = cids_unmerged(ismember_locb(sp.clu, sp.cids));
sp_new.st   = sp.st;
end