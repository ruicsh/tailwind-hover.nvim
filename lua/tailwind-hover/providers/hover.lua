-- Hover.nvim custom provider
-- https://github.com/lewis6991/hover.nvim

local parser = require("tailwind-hover.treesitter")

local ENABLED_FILETYPES = {
	"html",
	"javascript",
	"typescript",
	"javascriptreact",
	"typescriptreact",
	"vue",
	"svelte",
	"astro",
	"lua",
}

return {
	name = "Tailwind CSS",
	priority = 1000,
	enabled = function(bufnr)
		local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
		return vim.tbl_contains(ENABLED_FILETYPES, ft)
	end,
	execute = function(params, done)
		local bufnr = params.bufnr
		local tw_classes, range = parser.get_tw_classes_at_cursor(bufnr)

		if tw_classes and #tw_classes > 0 then
			local cb = function(css_classes, unknown_class_names)
				local lines = {}

				for _, css_class in ipairs(css_classes) do
					table.insert(lines, #lines + 1, css_class)
				end

				if #unknown_class_names > 0 then
					table.insert(lines, "")
					table.insert(lines, "/* Unknown classes */")
					for _, class_name in ipairs(unknown_class_names) do
						table.insert(lines, #lines + 1, "." .. class_name .. " {}")
					end
				end

				done({ lines = lines, filetype = "css" })
			end

			parser.parse_with_tailwind({ input = tw_classes, range = range, bufnr = bufnr }, cb)
		else
			done(nil)
		end
	end,
}
