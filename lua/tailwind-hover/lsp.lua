local utils = require("tailwind-hover.utils")

local M = {}

-- Get the tailwindcss LSP client
local function get_tw_client()
	local clients = vim.lsp.get_clients({ name = "tailwindcss" })

	if not clients[1] then
		print("No tailwindcss client found")
		return
	end

	return clients[1]
end

M.parse_with_tailwind = function(params, cb)
	local bufnr = params.bufnr
	local range = params.range
	local input = params.input

	local tw = get_tw_client()
	if tw == nil then
		vim.notify("No tailwindcss client found", vim.log.levels.ERROR)
		return
	end

	local css_classes = {}
	local unknown_classes = {}

	local init_col = range[2]
	local init_row = range[1]

	local tw_classes = utils.split(input, " ", init_col, init_row)

	for current, tw_class in ipairs(tw_classes) do
		tw.request("textDocument/hover", {
			textDocument = vim.lsp.util.make_text_document_params(),
			position = {
				line = tw_class.row,
				character = tw_class.col,
			},
		}, function(err, result, _, _)
			if err then
				vim.notify("Error getting tailwind config", vim.log.levels.ERROR)
				return
			end

			if result == nil then
				table.insert(unknown_classes, #unknown_classes + 1, tw_class.str)
			else
				local fresh_css_classes = vim.split(result.contents.value, "\n")

				for _, fresh_css_class in ipairs(fresh_css_classes or {}) do
					table.insert(css_classes, #css_classes + 1, fresh_css_class)
				end
			end

			-- Return when all classes have been processed
			if current == #tw_classes then
				cb(css_classes, unknown_classes)
			end
		end, bufnr)
	end
end

return M
