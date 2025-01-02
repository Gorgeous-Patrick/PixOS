return {
	{ "projekt0n/github-nvim-theme" },
	{
		"uloco/bluloco.nvim",
		lazy = false,
		priority = 1000,
		dependencies = { "rktjmp/lush.nvim" },
		config = function()
			-- your optional config goes here, see below.
		end,
	},
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}
