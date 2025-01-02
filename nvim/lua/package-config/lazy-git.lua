local wk = require("which-key")
wk.register({
	["<leader>g"] = {
		name = "Lazy Git",
		g = { "<cmd>LazyGit<cr>", "LazyGit" },
		f = { "<cmd>LazyGitFilter<cr>", "Lazy Git Filter" },
		a = { "<cmd>LazyGitFilterCurrentFile<cr>", "LazyGit Filter Current File" },
		c = { "<cmd>LazyGitCurrentFile<cr>", "LazyGit Current File" },
	},
})
