vim.api.nvim_create_user_command("TailwindHover", function()
	require("tailwind-hover").hover()
end, {})
