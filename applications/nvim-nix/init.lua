-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- OR setup with some options

-- vim.keymap.set({ "i" }, "jk", "<Esc>", {})
-- vim.keymap.set({ "n", "v" }, "<C-n>", ":NvimTreeToggle<CR>", {})
-- vim.keymap.set({ "n", "v" }, "<S-h>", "^", {})
-- vim.keymap.set({ "n", "v" }, "<S-l>", "$", {})
vim.keymap.set("n", "<S-n>", ":TablineBufferNext<CR>", {})
vim.keymap.set("n", "<S-p>", ":TablineBufferPrevious<CR>", {})

-- vim.keymap.set({"n", "t"}, "<C-CR>", "<cmd>ToggleTerm direction=float<CR>", {})
vim.keymap.set('n','gD','<cmd>lua vim.lsp.buf.declaration()<CR>')
vim.keymap.set('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')


-- local lsp_zero = require("lsp-zero")
--
-- 	lsp_zero.on_attach(function(client, bufnr)
-- 	-- see :help lsp-zero-keybindings to learn the available actions
-- 	lsp_zero.default_keymaps({
-- 	buffer = bufnr,
-- 	preserve_mappings = false
-- 	})
-- end)

require("lazy-lsp").setup {
  excluded_servers = {
    "denols", -- Prefer eslint
    "basepyright",
    "pylyzer"
  }
}

-- Set up nvim-cmp.
-- local cmp = require("cmp")

-- cmp.setup({
-- 	snippet = {
-- 		-- REQUIRED - you must specify a snippet engine
-- 		expand = function(args)
-- 			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
-- 			-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
-- 			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
-- 			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
-- 			-- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
-- 		end,
-- 	},
-- 	window = {
-- 		-- completion = cmp.config.window.bordered(),
-- 		-- documentation = cmp.config.window.bordered(),
-- 	},
-- 	mapping = cmp.mapping.preset.insert({
-- 		["<Tab>"] = cmp.mapping(function(fallback)
-- 			if cmp.visible() then
-- 				cmp.select_next_item()
-- 			else
-- 				fallback()
-- 			end
-- 		end, { "i", "s" }),
-- 		["<S-Tab>"] = cmp.mapping(function(fallback)
-- 			if cmp.visible() then
-- 				cmp.select_prev_item()
-- 			else
-- 				fallback()
-- 			end
-- 		end, { "i", "s" }),
-- 		["<C-b>"] = cmp.mapping.scroll_docs(-4),
-- 		["<C-f>"] = cmp.mapping.scroll_docs(4),
-- 		["<C-Space>"] = cmp.mapping.complete(),
-- 		["<C-e>"] = cmp.mapping.abort(),
-- 		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
-- 	}),
-- 	sources = cmp.config.sources({
-- 		{ name = "nvim_lsp" },
-- 		{ name = "vsnip" }, -- For vsnip users.
-- 		-- { name = 'luasnip' }, -- For luasnip users.
-- 		-- { name = 'ultisnips' }, -- For ultisnips users.
-- 		-- { name = 'snippy' }, -- For snippy users.
-- 	}, {
-- 		{ name = "buffer" },
-- 	}),
-- })
--
-- -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
-- -- Set configuration for specific filetype.
-- --[[ cmp.setup.filetype('gitcommit', {
--     sources = cmp.config.sources({
--       { name = 'git' },
--     }, {
--       { name = 'buffer' },
--     })
--  })
--  require("cmp_git").setup() ]]
-- --
--
-- -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline({ "/", "?" }, {
-- 	mapping = cmp.mapping.preset.cmdline(),
-- 	sources = {
-- 		{ name = "buffer" },
-- 	},
-- })
--
-- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(":", {
-- 	mapping = cmp.mapping.preset.cmdline(),
-- 	sources = cmp.config.sources({
-- 		{ name = "path" },
-- 	}, {
-- 		{ name = "cmdline" },
-- 	}),
-- 	matching = { disallow_symbol_nonprefix_matching = false },
-- })

-- Set up lspconfig.
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
--  capabilities = capabilities
-- }
--
require("auto-save").setup{}
require("nvim-autopairs").setup{}
