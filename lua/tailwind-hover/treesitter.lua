local utils = require("tailwind-hover.utils")

-- Get the tailwindcss LSP client
local function get_tw_client()
	local clients = vim.lsp.get_clients({ name = "tailwindcss" })

	if not clients[1] then
		print("No tailwindcss client found")
		return
	end

	return clients[1]
end

local M = {}

-- Get the list of tw-clases at the current cursor position
M.get_tw_classes_at_cursor = function(bufnr)
	local node = vim.treesitter.get_node({ bufnr = bufnr, ignore_injections = false })
	if node == nil then
		print("No node found")
		return {}
	end

	local type = node:type()
	if type ~= "string_fragment" and type ~= "attribute_value" then
		return {}
	end

	-- Get the attribute node
	local attribute = node:parent():parent()
	if attribute == nil then
		return {}
	end

	-- Check if the parent is an attribute or jsx_attribute
	local attribute_type = attribute:type()
	if attribute_type ~= "attribute" and attribute_type ~= "jsx_attribute" then
		return {}
	end

	-- Check if the attribute is class or className
	local attribute_text = vim.treesitter.get_node_text(attribute, bufnr)
	if not (vim.startswith(attribute_text, "class=") or vim.startswith(attribute_text, "className=")) then
		return {}
	end

	local values = vim.treesitter.get_node_text(node, bufnr)
	local range = { vim.treesitter.get_node_range(node) }

	return values, range
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
