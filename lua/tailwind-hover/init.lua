local hover = require("tailwind-hover.hover")
local treesitter = require("tailwind-hover.treesitter")
local lsp = require("tailwind-hover.lsp")

local defaults = {
	border = vim.o.winborder,
	title = "",
	fallback_to_lsp_hover = false,
	fallback_cmd = nil,
}

local options = {}

function fallback()
	if options.fallback_cmd then
		vim.cmd(options.fallback_cmd)
	elseif options.fallback_to_lsp_hover then
		vim.lsp.buf.hover()
	end
end

local M = {}

function M.setup(opts)
	options = options or {}
	options = vim.tbl_deep_extend("force", defaults, opts or {})
end

function M.hover()
	local bufnr = vim.api.nvim_get_current_buf()

	local tw_classes, range = treesitter.get_tw_classes_at_cursor(bufnr)

	if #tw_classes > 0 then
		local cb = function(css_classes, unknown_class_names)
			hover.show(css_classes, unknown_class_names, options)
		end

		lsp.parse_with_tailwind({ input = tw_classes, range = range, bufnr = bufnr }, cb)
	else
		fallback()
	end
end

return M
