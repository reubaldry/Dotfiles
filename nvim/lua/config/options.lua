-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.termguicolors = true

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "md" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Set tab/indent settings for C files
--vim.api.nvim_create_autocmd("FileType", {
--  pattern = "c",
--  callback = function()
--    vim.bo.tabstop = 4 -- Number of spaces that a <Tab> counts for
--    vim.bo.shiftwidth = 4 -- Number of spaces for each indentation
--    vim.bo.expandtab = true -- Use spaces instead of tabs
--  end,
--})

LazyVim.terminal.setup("Ghostty")
