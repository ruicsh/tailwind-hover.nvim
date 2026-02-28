local M = {}

-- Get the list of tw-clases at the current cursor position
M.get_tw_classes_at_cursor = function(bufnr)
	local node = vim.treesitter.get_node({ bufnr = bufnr, ignore_injections = false })
	if node == nil then
		print("No node found")
		return {}
	end

	local node_type = node:type()
	if node_type ~= "string_fragment" and node_type ~= "attribute_value" then
		return {}
	end

	-- Get the attribute node
	local attribute = node:parent()
	if attribute == nil then
		return {}
	end
	attribute = attribute:parent()
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

return M
