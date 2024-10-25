function out = get_dtype_byte(dtype)
out = numel(typecast(cast(0, dtype), 'uint8'));
end