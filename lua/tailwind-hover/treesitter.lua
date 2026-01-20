local utils = require("tailwind-hover.utils")

local standard = function(lang)
	return vim.treesitter.query.parse(
		lang,
		[[
    (attribute
      (attribute_name) @attr_name
        (quoted_attribute_value (attribute_value) @values)
        (#match? @attr_name "class")
    )
    ]]
	)
end

local tsx_parser = function()
	return {
		vim.treesitter.query.parse(
			"tsx",
			[[
            (jsx_attribute
              (property_identifier) @attr_name
              (#match? @attr_name "className")
              (string
              (string_fragment) @values
              )
            )
        ]]
		),
		vim.treesitter.query.parse(
			"tsx",
			[[
              (string
              (string_fragment) @values
              )
        ]]
		),
	}
end

-- For template strings
local typescript_parser = function()
	return {
		standard("html"),
	}
end

local astro_parser = function()
	return {
		standard("astro"),
	}
end

local vue_parser = function()
	return {
		standard("vue"),
	}
end

local svelte_parser = function()
	return {
		standard("svelte"),
	}
end

local html_parser = function()
	return {
		standard("html"),
	}
end

local templ_parser = function()
	return {
		standard("templ"),
	}
end

local parsers = {
	typescriptreact = tsx_parser,
	typescript = typescript_parser,
	astro = astro_parser,
	vue = vue_parser,
	svelte = svelte_parser,
	html = html_parser,
	templ = templ_parser,
}

local function get_treesitter(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	local ft = vim.bo[bufnr].ft

	if parsers[ft] == nil then
		return {
			standard("html"),
		}
	end

	return parsers[ft]()
end

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
		return
	end

	local parent = node:parent()
	if not parent then
		print("No parent found")
		return
	end

	local queries = get_treesitter(bufnr)
	if queries == nil then
		print("No parser found")
		return
	end

	local found_match = false
	for _, query in ipairs(queries) do
		if found_match then
			break
		end
		for id, node in query:iter_captures(parent, bufnr, 0, -1) do
			found_match = true
			local name = query.captures[id]

			if name == "values" then
				local values = vim.treesitter.get_node_text(node, bufnr)
				local range = { vim.treesitter.get_node_range(node) }

				return values, range
			end
		end
	end

	return {}
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
