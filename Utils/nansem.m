function out = nansem(x, varargin)
out  = nanstd(x, varargin{:})./sqrt(sum(~isnan(x), varargin{:}));
end
