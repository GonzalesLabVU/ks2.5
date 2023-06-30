%%  ACG correlation matrix
function acg_corr_matrix = compute_acg_corr(sp, varargin)
n_acg_to_keep     = 100;
n_acg_to_keep_log = 67;
temp_ids          = [1:size(sp.temps)] - 1;
n_temp            = numel(temp_ids);
acg_array = nan(n_temp, n_acg_to_keep);
acg_array_log = nan(n_temp, n_acg_to_keep_log);
for i = 1:n_temp
    st_ = sp.st(sp.clu == temp_ids(i));
    if isempty(st_)
        continue
    end
    [n_lin_, x_lin_,n_log_,x_log_] = myACG(st_, [], []);
    acg_array(i,:) = x_lin_(1:n_acg_to_keep);
    acg_array_log(i,:) = x_log_(1:n_acg_to_keep_log);
end
acg_corr_matrix = corr(acg_array_log');
end