-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Ensure the FocusGained event properly triggers the terminal
vim.api.nvim_create_autocmd("FocusGained", {
  pattern = "*",
  callback = function()
    vim.fn.system("open -a iTerm") -- Use vim.fn.system instead of ! command
    vim.cmd("redraw!")
  end,
})

-- Create the augroup for VimTeX event
local augroup = vim.api.nvim_create_augroup("vimtex_event_focus", { clear = true })

-- Define a Lua version of TexFocusVim
local function TexFocusVim()
  vim.fn.system("open -a iTerm")
  vim.cmd("redraw!")
end

-- Attach it to the VimTeX event
vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventViewReverse",
  callback = TexFocusVim,
  group = augroup,
})
