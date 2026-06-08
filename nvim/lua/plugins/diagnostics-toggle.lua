return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local diagnostics_mode = "all"

      local function toggle_diagnostics_severity()
        if diagnostics_mode == "all" then
          vim.diagnostic.config({
            virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
            signs = { severity = { min = vim.diagnostic.severity.ERROR } },
            underline = { severity = { min = vim.diagnostic.severity.ERROR } },
          })
          diagnostics_mode = "errors"
          print("Diagnostics: Errors only")
        else
          vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
          })
          diagnostics_mode = "all"
          print("Diagnostics: All")
        end
      end

      vim.keymap.set("n", "<leader>tw", toggle_diagnostics_severity, {
        desc = "Toggle warnings",
      })
    end,
  },
}
