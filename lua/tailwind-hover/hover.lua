local utils = require("tailwind-hover.utils")

local M = {}

-- Display hover results in a floating window
function M.show(statements, unknown, options)
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

	vim.lsp.util.open_floating_preview(formatted, "css", {
		border = options.border or vim.o.winborder,
		focusable = true,
		width = longest,
		height = height,
		title = title,
	})
end

return M
