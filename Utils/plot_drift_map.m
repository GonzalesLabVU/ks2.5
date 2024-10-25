function plot_drift_map(rez)
% Plots the same drift traces and spike map as in the sorting process. 
% Load "preproc_rez.mat" for efficiency.
st3 = rez.st0;
ops = rez.ops;
figure;
set(gcf, 'Color', 'w')

% plot the shift trace in um
plot(rez.dshift)
xlabel('batch number')
ylabel('drift (um)')
title('Estimated drift traces')
drawnow

figure;
set(gcf, 'Color', 'w')
% raster plot of all spikes at their original depths
st_shift = st3(:,2); %+ imin(batch_id)' * dd;
spkTh = 8;
for j = spkTh:100
    % for each amplitude bin, plot all the spikes of that size in the
    % same shade of gray
    ix = st3(:, 3)==j; % the amplitudes are rounded to integers
    plot(st3(ix, 1)/ops.fs, st_shift(ix), '.', 'color', [1 1 1] * max(0, 1-j/40)) % the marker color here has been carefully tuned
    hold on
end
axis tight

xlabel('time (sec)')
ylabel('spike position (um)')
title('Drift map')

end