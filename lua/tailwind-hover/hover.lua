local utils = require("tailwind-hover.utils")

local M = {}

local hover_winid = nil

-- Display hover results in a floating window
function M.show(statements, unknown, options)
	-- If window exists, focus it
	if hover_winid and vim.api.nvim_win_is_valid(hover_winid) then
		vim.api.nvim_set_current_win(hover_winid)
		return
	end

	if #statements == 0 and #unknown == 0 then
		return
	end

	local formatted = {}

	for _, statement in ipairs(statements) do
		table.insert(formatted, #formatted + 1, " " .. statement)
	end

	-- Append unknown classes at the end if any
	if #unknown > 0 then
		table.insert(formatted, "")
		table.insert(formatted, "/* Unknown classes */")
		for _, class in ipairs(unknown) do
			table.insert(formatted, #formatted + 1, " ." .. class .. " {}")
		end
	end

	local title = options.title
	local longest = utils.get_longest(formatted, #title) + 10
	local height = #formatted + 1

	local _, winid = vim.lsp.util.open_floating_preview(formatted, "css", {
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
