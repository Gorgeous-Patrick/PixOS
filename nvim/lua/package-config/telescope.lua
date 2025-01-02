local builtin = require('telescope.builtin')
local wk = require("which-key")
wk.register({
	["<leader>f"] = {
		name = "Telescope",
        f = {builtin.find_files, "Find Files"},
        g = {builtin.live_grep, "Live Grep"},
        b = {builtin.buffers, "Buffers"},
        h = {builtin.help_tags, "Help Tags"},
	},
})
