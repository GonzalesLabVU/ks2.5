function [out, signature] = find_neuron_count(tbl, subject, session, varargin)
p = inputParser;
p.addParameter('remove_signature', false);
p.parse(varargin{:});
remove_signature = p.Results.remove_signature;

match_idx = false([size(tbl, 1), 1]);

if isempty(tbl)
    out = [];
    return;
end

if isempty(subject)
    out = max(tbl.Neuron);
    return
end

if isempty(session)
    filename_key = sprintf('%s', upper(subject));
    match_idx = cellfun(@(x)  contains(x, filename_key), [tbl.Filename]);
else
    while (sum(match_idx) == 0) && session > 0
        filename_key = sprintf('%s%03.f', upper(subject), session);
        match_idx = cellfun(@(x)  contains(x, filename_key), [tbl.Filename]);
        session = session - 1;
    end
end
out = max(tbl.Neuron(match_idx));
if remove_signature
    formatted_number = sprintf('%05d', out);
    signature = formatted_number(1:2);
    out = int32(str2double(formatted_number(3:end)));
end
end