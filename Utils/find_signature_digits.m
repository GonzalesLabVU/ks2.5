function out = find_signature_digits(neuron_table, subject)
lastest_number = sprintf('%05d', find_neuron_count(neuron_table, subject, []));
out = lastest_number(1:2);
if strcmp(lastest_number, '00000')
    lastest_number = sprintf('%05d', find_neuron_count(neuron_table, [], []));
    out = num2str(int32(str2double(lastest_number(1:2))) + 1);
end
end