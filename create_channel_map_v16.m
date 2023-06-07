%  create a channel map file

Nchannels = 16; % number of channels
connected = true(1, Nchannels);
chanMap0ind = 0:(Nchannels - 1);
chanMap   = chanMap0ind + 1;

y_pitch = 150;
xcoords = zeros(size(chanMap));
ycoords = 0:y_pitch:(y_pitch * (Nchannels - 1));
kcoords   = ones(size(chanMap));

name = 'Linear_16_ch_150_pitch_plexon_V';

save(fullfile([name,'.mat']), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'name')
