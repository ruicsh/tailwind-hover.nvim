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

	local tw_classes, range = parser.get_tw_classes_at_cursor(bufnr)

	if #tw_classes > 0 then
		local cb = function(css_classes, unknown_class_names)
			hover.show(css_classes, unknown_class_names, options)
		end

		parser.parse_with_tailwind({ input = tw_classes, range = range, bufnr = bufnr }, cb)
	end
end

return M
