vim.opt.number = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.cmd.colorscheme "sorbet"
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set("n", "<leader>r", ":vnew | r ! ruff check '#'<CR>", { desc = "Run ruff check on buffer and show results on vertical window" })
vim.keymap.set("n", "<Esc>", ":bd!<CR>", { desc = "Close buffer without saving it" })
vim.keymap.set("n", "<leader><leader>", ":noh<CR>", { desc = "Remove search term highligh" })
vim.keymap.set("n", "<leader>gb", ":vnew | r ! git blame '#' -L", { desc = "Git blame a range of lines" })
vim.keymap.set("n", "<leader>gs", ":new | r ! git show ", { desc = "Git show a commit" })
vim.keymap.set("n", "<leader>gd", ":vnew | set filetype=diff | r ! git diff '#' ", { desc = "Git diff" })
vim.keymap.set("n", "<leader>gt", ":vnew | r ! git status<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>f", ":browse oldfiles<CR>", { desc = "List recently opened files" })
