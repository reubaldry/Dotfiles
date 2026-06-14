return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      terminal_colors = true,

      on_colors = function(colors)
        -- Polar Night (Darkest colors, mostly used for backgrounds/UI)
        colors.nord0 = "#2E3440" -- Base background (overridden by transparency anyway)
        colors.nord1 = "#3B4252" -- Elevated backgrounds (popups, sidebars)
        colors.nord2 = "#434C5E" -- Selection background
        colors.nord3 = "#8f9db8" -- Comments and invisible characters

        -- Snow Storm (Brightest colors, mostly used for text)
        colors.nord4 = "#D8DEE9" -- Standard text / variables
        colors.nord5 = "#E5E9F0" -- Subtle text highlights
        colors.nord6 = "#ECEFF4" -- Brightest text / titles

        -- Frost (The core Nord identity: teals and blues)
        colors.nord7 = "#8FBCBB" -- Standout blue/teal
        colors.nord8 = "#88C0D0" -- Primary accent / methods / functions
        colors.nord9 = "#81A1C1" -- Secondary accent / syntax tags
        colors.nord10 = "#5E81AC" -- Deep blue / keywords

        -- Aurora (The warning, error, and colorful syntax accents)
        colors.nord11 = "#BF616A" -- Red (Errors / Deletions)
        colors.nord12 = "#D08770" -- Orange (Warnings / Numbers)
        colors.nord13 = "#EBCB8B" -- Yellow (Classes / Types)
        colors.nord14 = "#A3BE8C" -- Green (Strings / Additions)
        colors.nord15 = "#B48EAD" -- Purple (Numbers / Special characters)
      end,

      on_highlights = function(hl, colors)
        hl.CursorLine = { bg = "NONE" }
        hl.CursorLineNr = { fg = colors.nord4, bold = true, bg = "NONE" }
        hl.LineNr = { fg = colors.nord9, bg = "NONE" }

        hl.Comment = { fg = colors.nord3, italic = true }
        hl["@comment"] = { link = "Comment" }

        hl.NormalFloat = { bg = "NONE" }
        hl.FloatBorder = { bg = "NONE" }
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
