%%  Distance matrix of cluster xy position estimated from 2D template
function distance_matrix = compute_xy_distance(sp, varargin)
y_distance_matrix = sp.templateYs - sp.templateYs';
x_distance_matrix = sp.templateXs - sp.templateXs';
distance_matrix = sqrt(y_distance_matrix.^2 + x_distance_matrix.^2);
end