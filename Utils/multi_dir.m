function out = multi_dir(dirs)
out = [];
if iscell(dirs)
    for i = 1:numel(dirs)
        if ~isempty(out)
            out = [out; dir(dirs{i})];
        else
            out = dir(dirs{i});
        end
    end
else
    out = dir(dirs);
end
end