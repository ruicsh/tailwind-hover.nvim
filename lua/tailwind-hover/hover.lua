local utils = require("tailwind-hover.utils")

local M = {}

local hover_winid = nil

-- Display hover results in a floating window
function M.show(css_classes, unknown_class_names, options)
	-- If window exists, focus it
	if hover_winid and vim.api.nvim_win_is_valid(hover_winid) then
		vim.api.nvim_set_current_win(hover_winid)
		return
	end

	if #css_classes == 0 and #unknown_class_names == 0 then
		return
	end

	local contents = {}

	for _, css_class in ipairs(css_classes) do
		table.insert(contents, #contents + 1, " " .. css_class)
	end

	-- Append unknown classes at the end if any
	if #unknown_class_names > 0 then
		table.insert(contents, "")
		table.insert(contents, "/* Unknown classes */")
		for _, class_name in ipairs(unknown_class_names) do
			table.insert(contents, #contents + 1, " ." .. class_name .. " {}")
		end
	end

	local title = options.title
	local longest = utils.get_longest(contents, #title) + 10
	local height = #contents + 1

	local _, winid = vim.lsp.util.open_floating_preview(contents, "css", {
		border = options.border or vim.o.winborder,
		focusable = true,
		width = longest,
		height = height,
		title = title,
	})

	-- Store the window id to focus later
	hover_winid = winid

	-- Clear winid when window closes
	vim.api.nvim_create_autocmd("WinClosed", {
		once = true,
		callback = function(args)
			if tonumber(args.match) == hover_winid then
				hover_winid = nil
			end
		end,
	})
end

return M
