
vim.keymap.set({ "i" }, "jk", "<Esc>", {})
vim.keymap.set({ "n", "v" }, "<C-n>", ":NvimTreeToggle<CR>", {})
vim.keymap.set({ "n", "v" }, "<S-h>", "^", {})
vim.keymap.set({ "n", "v" }, "<S-l>", "$", {})
vim.keymap.set("n", "<S-n>", ":TablineBufferNext<CR>", {})
vim.keymap.set("n", "<S-p>", ":TablineBufferPrevious<CR>", {})

vim.keymap.set({"n", "t"}, "<C-CR>", "<cmd>ToggleTerm direction=float<CR>", {})
