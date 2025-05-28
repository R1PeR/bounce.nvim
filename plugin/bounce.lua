vim.api.nvim_create_user_command('BounceShowWordNumbers', require("bounce").show_word_numbers, {desc = "Show word jump position numbers"})
vim.api.nvim_create_user_command('BounceHideWordNumbers', require("bounce").hide_word_numbers, {desc = "Hide word jump position numbers"})
