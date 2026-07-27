-- Folder-specific sorting: Downloads by mtime (newest first), everything
-- else with the global default. From https://yazi-rs.github.io/docs/tips
local function setup()
	ps.sub("ind-sort", function(opt)
		local cwd = cx.active.current.cwd
		if cwd:ends_with("Downloads") then
			opt.by, opt.reverse, opt.dir_first = "mtime", true, false
		else
			opt.by, opt.reverse, opt.dir_first = "alphabetical", false, true
		end
		return opt
	end)
end

return { setup = setup }
