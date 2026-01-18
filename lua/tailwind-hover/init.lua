local hover = require("tailwind-hover.hover")
local parser = require("tailwind-hover.treesitter")

local defaults = {
	title = "",
}

local options = {}

local M = {}

function M.setup(opts)
	options = options or {}
	options = vim.tbl_deep_extend("force", defaults, opts or {})
end

function M.hover()
	local bufnr = vim.api.nvim_get_current_buf()

	local values, range = parser.get_values_at_cursor(bufnr)

	if #values > 0 then
		local params = {
			str = values,
			range = range,
			bufnr = bufnr,
		}

		local cb = function(results, unknown_classes)
			hover.show(results, unknown_classes, options)
		end

		parser.parse_with_tailwind(params, cb)
	end
end

return M
