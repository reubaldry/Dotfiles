return {
  "lervag/vimtex",
  lazy = false, -- vimtex must not be lazy-loaded
  init = function()
    vim.g.vimtex_view_method = "skim"

    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 1

    -- optional but recommended
    vim.g.vimtex_compiler_method = "latexmk"
  end,
}
