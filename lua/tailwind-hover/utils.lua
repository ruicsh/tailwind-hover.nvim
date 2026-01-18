local M = {}

-- Get the length of the longest string in a table
M.get_longest = function(t, init_len)
	local longest = init_len or 0

	for _, value in ipairs(t) do
		if #value > longest then
			longest = #value
		end
	end

	return longest
end

-- Count leading whitespace in a string
M.count_leading_whitespace = function(line)
	local leadingWhitespace = string.match(line, "^[ \t]*")
	return leadingWhitespace and #leadingWhitespace or 0
end

-- Split a string by a separator and return a table of substrings with their positions
M.split = function(inputstr, sep, init_col, init_row)
	if sep == nil then
		sep = "%s"
	end

	local t = {}

	-- If there are mulitple new lines
	local row_offset = init_row

	for row in string.gmatch(inputstr, "([^\n]+)") do
		local offset = 0
		local whitespace = M.count_leading_whitespace(row)
		local base_col = init_col

		if whitespace ~= 0 then
			base_col = whitespace
		end

		for str in string.gmatch(row, "([^" .. sep .. "]+)") do
			local start_pos, _ = row:find(str, offset + 1, true)
			local new_col = base_col + start_pos - 1

			table.insert(t, {
				str = str,
				col = new_col,
				row = row_offset,
			})
			offset = offset + #str + 1
		end

		-- Increment for each new line
		row_offset = row_offset + 1
	end
	return t
end
return M
