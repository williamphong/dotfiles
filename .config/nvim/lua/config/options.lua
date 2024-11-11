-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

vim.g.mapleader = " "
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.expandtab = true
vim.opt.scrolloff = 10
-- vim.opt.shell = "iterm"
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.ignorecase = true
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"

-- Enable swap, backup, and undo files
vim.opt.swapfile = true
vim.opt.backup = true
vim.opt.undofile = true

-- Use relative line numbers
opt.relativenumber = true

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })
