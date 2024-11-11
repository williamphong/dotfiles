-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Check keymappings with :verbose map "key"
-- Add any additional keymaps here
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

---------  [MOVEMENT] ---------
-- Better line start/end
keymap.set("n", "H", "^", opts)
keymap.set("n", "L", "$", opts)
keymap.set("v", "H", "^", opts)
keymap.set("v", "L", "$", opts)

-- Move selected text /updown
keymap.set("v", "J", ":m '>+1<CR>gv==kgvo<esc>=kgvo", { desc = "move highlighted text down" })
keymap.set("v", "K", ":m '<-2<CR>gv==jgvo<esc>=jgvo", { desc = "move highlighted text up" })

---------  [BINDS] ---------

-- Better escape
keymap.set("i", "kj", "<ESC>", opts)
keymap.set("n", "<ESC>", "<ESC>:noh<CR>", opts)

-- Better yank (goes back to end of select)
keymap.set("v", "y", "ygv<Esc>", opts)
-- manually setting the bind with :vnoremap y ygv<Esc> // "may`a" is similar

-- Use <Tab> to cycle through buffers in tab
keymap.set("n", "<Tab>", "<C-W>w")
keymap.set("n", "<S-Tab>", "<C-W>W")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G", opts)
-- keymap.set("n", "<C-v>", "P", opts)

-- Increment/Decrement numbers
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Enter deletes word and enters insert mode
-- keymap.set("n", "<cr>", "ciw")

--------- [ WINDOW] ---------
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", "vsplit<Return>", opts)
-- Close Window
keymap.set("n", "sw", ":close<Return>", opts)

-- Move window
-- keymap.set("n", "sh", "<C-w>h")
-- keymap.set("n", "sk", "<C-w>k")
-- keymap.set("n", "sj", "<C-w>j")
-- keymap.set("n", "sl", "<C-w>l")
