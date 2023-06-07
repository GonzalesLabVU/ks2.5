function chanMapFile = find_chanMapFile(oe)
n_chan = oe.oe_info.continuous.num_channels;
switch n_chan
    case 16
        chanMapFile = 'Linear_16_ch_150_pitch_plexon_V.mat';
    case 32
        chanMapFile = 'Linear_32_ch_75_pitch_plexon_S.mat';
    case 128
        chanMapFile = 'DA128-2_chanMap.mat';
    case num2cell(128 + [1:8])
        chanMapFile = sprintf('DA128-2_chanMap_%dadc.mat', n_chan - 128);
    case 256
        chanMapFile = 'DA128-2X2_chanMap.mat';
    case mat2cell(256 + [1:8])
        chanMapFile = sprintf('DA128-2X2_chanMap_%dadc.mat', n_chan - 256);
end