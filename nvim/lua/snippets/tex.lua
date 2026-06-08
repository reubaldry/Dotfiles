local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local types = require("luasnip.util.types")
local events = require("luasnip.util.events")
local conds = require("luasnip.extras.expand_conditions")

local function in_mathzone()
  local ok, vimtex = pcall(vim.fn["vimtex#syntax#in_mathzone"])
  return ok == true and vimtex == 1
end

local function in_text()
  return not in_mathzone()
end

local function line_begin()
  return conds.line_begin()
end

local function rec_matrix_rows()
  return sn(nil, {
    c(1, {
      t(""),
      sn(nil, {
        t({ " \\\\", "" }),
        i(1),
        d(2, rec_matrix_rows, {}),
      }),
    }),
  })
end

local function identity_matrix(_, snip)
  local n = tonumber(snip.captures[1]) or 1
  local rows = {}
  for row = 1, n do
    local cols = {}
    for col = 1, n do
      cols[#cols + 1] = tostring(row == col and 1 or 0)
    end
    rows[#rows + 1] = table.concat(cols, " & ")
  end
  return sn(nil, t({ "\\begin{pmatrix}", table.concat(rows, " \\\\\n"), "\\end{pmatrix}" }))
end

local greek = table.concat({
  "alpha",
  "beta",
  "gamma",
  "Gamma",
  "delta",
  "Delta",
  "epsilon",
  "varepsilon",
  "zeta",
  "theta",
  "Theta",
  "vartheta",
  "iota",
  "kappa",
  "lambda",
  "Lambda",
  "sigma",
  "Sigma",
  "upsilon",
  "Upsilon",
  "omega",
  "Omega",
  "phi",
  "varphi",
  "mu",
  "nu",
  "xi",
  "Xi",
  "rho",
  "tau",
  "eta",
  "psi",
  "Psi",
  "pi",
  "Pi",
}, "|")

local symbol = table.concat({
  "infty",
  "partial",
  "nabla",
  "forall",
  "exists",
  "times",
  "cdot",
  "pm",
  "mp",
  "to",
  "mapsto",
  "implies",
  "impliedby",
  "subseteq",
  "supseteq",
  "emptyset",
  "setminus",
  "leftrightarrow",
  "neq",
  "geq",
  "leq",
  "gg",
  "ll",
  "sim",
  "simeq",
  "propto",
  "parallel",
}, "|")

local more_symbols = table.concat({
  "sin",
  "cos",
  "tan",
  "arcsin",
  "arccos",
  "arctan",
  "csc",
  "sec",
  "cot",
  "sinh",
  "cosh",
  "tanh",
  "coth",
  "log",
  "ln",
  "exp",
  "det",
  "Re",
  "Im",
}, "|")

local autos = {
  -- Math mode wrappers
  s({ trig = "mk", snippetType = "autosnippet", condition = in_text }, fmta("$<>$", { i(1) })),
  s({ trig = "dm", snippetType = "autosnippet", condition = in_text }, fmta("$$<>$$", { i(1) })),
  s(
    { trig = "beg", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\begin{<>}<>\\end{<>}", { i(1), i(2), rep(1) })
  ),

  -- Greek letters
  s({ trig = "@a", snippetType = "autosnippet", condition = in_mathzone }, t("\\alpha")),
  s({ trig = "@b", snippetType = "autosnippet", condition = in_mathzone }, t("\\beta")),
  s({ trig = "@g", snippetType = "autosnippet", condition = in_mathzone }, t("\\gamma")),
  s({ trig = "@G", snippetType = "autosnippet", condition = in_mathzone }, t("\\Gamma")),
  s({ trig = "@d", snippetType = "autosnippet", condition = in_mathzone }, t("\\delta")),
  s({ trig = "@D", snippetType = "autosnippet", condition = in_mathzone }, t("\\Delta")),
  s({ trig = "@e", snippetType = "autosnippet", condition = in_mathzone }, t("\\epsilon")),
  s({ trig = ":e", snippetType = "autosnippet", condition = in_mathzone }, t("\\varepsilon")),
  s({ trig = "@z", snippetType = "autosnippet", condition = in_mathzone }, t("\\zeta")),
  s({ trig = "@t", snippetType = "autosnippet", condition = in_mathzone }, t("\\theta")),
  s({ trig = "@T", snippetType = "autosnippet", condition = in_mathzone }, t("\\Theta")),
  s({ trig = ":t", snippetType = "autosnippet", condition = in_mathzone }, t("\\vartheta")),
  s({ trig = "@i", snippetType = "autosnippet", condition = in_mathzone }, t("\\iota")),
  s({ trig = "@k", snippetType = "autosnippet", condition = in_mathzone }, t("\\kappa")),
  s({ trig = "@l", snippetType = "autosnippet", condition = in_mathzone }, t("\\lambda")),
  s({ trig = "@L", snippetType = "autosnippet", condition = in_mathzone }, t("\\Lambda")),
  s({ trig = "@s", snippetType = "autosnippet", condition = in_mathzone }, t("\\sigma")),
  s({ trig = "@S", snippetType = "autosnippet", condition = in_mathzone }, t("\\Sigma")),
  s({ trig = "@u", snippetType = "autosnippet", condition = in_mathzone }, t("\\upsilon")),
  s({ trig = "@U", snippetType = "autosnippet", condition = in_mathzone }, t("\\Upsilon")),
  s({ trig = "@o", snippetType = "autosnippet", condition = in_mathzone }, t("\\omega")),
  s({ trig = "@O", snippetType = "autosnippet", condition = in_mathzone }, t("\\Omega")),
  s({ trig = "ome", snippetType = "autosnippet", condition = in_mathzone }, t("\\omega")),
  s({ trig = "Ome", snippetType = "autosnippet", condition = in_mathzone }, t("\\Omega")),
  s({ trig = "vph", snippetType = "autosnippet", condition = in_mathzone }, t("\\varphi")),
  s({ trig = "tau", snippetType = "autosnippet", condition = in_mathzone }, t("\\tau")),

  -- Text environment
  s({ trig = "text", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\text{<>}<>", { i(1), i(2) })),
  s({ trig = '"', snippetType = "autosnippet", condition = in_mathzone }, fmta("\\text{<>}<>", { i(1), i(2) })),

  -- Basic operations
  s({ trig = "sr", snippetType = "autosnippet", condition = in_mathzone }, t("^{2}")),
  s({ trig = "cb", snippetType = "autosnippet", condition = in_mathzone }, t("^{3}")),
  s({ trig = "^", snippetType = "autosnippet", condition = in_mathzone }, fmta("^{<>}<>", { i(1), i(2) })),
  s({ trig = "_", snippetType = "autosnippet", condition = in_mathzone }, fmta("_{<>}<>", { i(1), i(2) })),
  s({ trig = "sts", snippetType = "autosnippet", condition = in_mathzone }, fmta("_\\text{<>}", { i(1) })),
  s({ trig = "sq", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\sqrt{ <> }<>", { i(1), i(2) })),
  s(
    { trig = "//", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\frac{<>}{<>}<>", { i(1), i(2), i(3) })
  ),
  s({ trig = "ee", snippetType = "autosnippet", condition = in_mathzone }, fmta("e^{ <> }<>", { i(1), i(2) })),
  s({ trig = "invs", snippetType = "autosnippet", condition = in_mathzone }, t("^{-1}")),
  s(
    { trig = "([A-Za-z])(%d)", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    fmta("<>_{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    })
  ),
  s(
    {
      trig = "([^\\])(exp|log|ln)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end)
  ),
  s({ trig = "conj", snippetType = "autosnippet", condition = in_mathzone }, t("^{*}")),
  s({ trig = "Re", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathrm{Re}")),
  s(
    { trig = "res", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\mathrm{Res}(<>) <>", { i(1), i(2) })
  ),
  s({ trig = "Im", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathrm{Im}")),
  s({ trig = "bf", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\mathbf{<>}", { i(1) })),
  s({ trig = "rm", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\mathrm{<>}<>", { i(1), i(2) })),

  -- Linear algebra
  s(
    { trig = "([^\\])(det)", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end)
  ),
  s({ trig = "trace", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathrm{Tr}")),

  -- Decorators
  s(
    { trig = "([a-zA-Z])hat", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    { trig = "([a-zA-Z])bar", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return "\\bar{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    {
      trig = "([a-zA-Z])ddot",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      priority = 1000,
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\ddot{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    { trig = "([a-zA-Z])tilde", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return "\\tilde{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    { trig = "([a-zA-Z])und", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return "\\underline{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    { trig = "([a-zA-Z])over", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return "\\overline{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    { trig = "([a-zA-Z])vec", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return "\\vec{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    { trig = "([a-zA-Z]),%.", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    { trig = "([a-zA-Z])%.,", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "),%.",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\boldsymbol{\\" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. ")%.,",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\boldsymbol{\\" .. snip.captures[1] .. "}"
    end)
  ),
  s({ trig = "hat", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\hat{<>}<>", { i(1), i(2) })),
  s({ trig = "bar", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\bar{<>}<>", { i(1), i(2) })),
  s({ trig = "ddot", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\ddot{<>}<>", { i(1), i(2) })),
  s({ trig = "cdot", snippetType = "autosnippet", condition = in_mathzone }, t("\\cdot")),
  s({ trig = "tilde", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\tilde{<>}<>", { i(1), i(2) })),
  s({ trig = "und", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\underline{<>}<>", { i(1), i(2) })),
  s({ trig = "vec", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\vec{<>}<>", { i(1), i(2) })),

  -- More auto-subscripts
  s(
    {
      trig = "([A-Za-z])_(%d%d)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end)
  ),
  s(
    {
      trig = "\\hat{([A-Za-z])}(%d)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end)
  ),
  s(
    {
      trig = "\\vec{([A-Za-z])}(%d)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\vec{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end)
  ),
  s(
    {
      trig = "\\mathbf{([A-Za-z])}(%d)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end)
  ),
  s({ trig = "xnn", snippetType = "autosnippet", condition = in_mathzone }, t("x_{n}")),
  s({ trig = "\\xii", snippetType = "autosnippet", condition = in_mathzone }, t("x_{i}")),
  s({ trig = "xjj", snippetType = "autosnippet", condition = in_mathzone }, t("x_{j}")),
  s({ trig = "xp1", snippetType = "autosnippet", condition = in_mathzone }, t("x_{n+1}")),
  s({ trig = "ynn", snippetType = "autosnippet", condition = in_mathzone }, t("y_{n}")),
  s({ trig = "yii", snippetType = "autosnippet", condition = in_mathzone }, t("y_{i}")),
  s({ trig = "yjj", snippetType = "autosnippet", condition = in_mathzone }, t("y_{j}")),

  -- Symbols
  s({ trig = "ooo", snippetType = "autosnippet", condition = in_mathzone }, t("\\infty")),
  s(
    { trig = "sum", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\sum_{<> = <>}^{<>} <>", { i(1, "n"), i(2, "1"), i(3, "\\infty"), i(4) })
  ),
  s({ trig = "prod", snippetType = "autosnippet", condition = in_mathzone }, t("\\prod")),
  s(
    { trig = "\\sum", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\sum_{<> = <>}^{<>} <>", { i(1, "n"), i(2, "1"), i(3, "\\infty"), i(4) })
  ),
  s(
    { trig = "\\prod", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\prod_{<> = <>}^{<>} <>", { i(1, "i"), i(2, "1"), i(3, "N"), i(4) })
  ),
  s(
    { trig = "lim", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\lim_{ <> \\to <> } <>", { i(1, "n"), i(2, "\\infty"), i(3) })
  ),
  s({ trig = "+-", snippetType = "autosnippet", condition = in_mathzone }, t("\\pm")),
  s({ trig = "-+", snippetType = "autosnippet", condition = in_mathzone }, t("\\mp")),
  s({ trig = "...", snippetType = "autosnippet", condition = in_mathzone }, t("\\dots")),
  s({ trig = "nabl", snippetType = "autosnippet", condition = in_mathzone }, t("\\nabla")),
  s({ trig = "del", snippetType = "autosnippet", condition = in_mathzone }, t("\\nabla")),
  s({ trig = "xx", snippetType = "autosnippet", condition = in_mathzone }, t("\\times")),
  s({ trig = "**", snippetType = "autosnippet", condition = in_mathzone }, t("\\cdot")),
  s({ trig = "para", snippetType = "autosnippet", condition = in_mathzone }, t("\\parallel")),
  s({ trig = "===", snippetType = "autosnippet", condition = in_mathzone }, t("\\equiv")),
  s({ trig = "!=", snippetType = "autosnippet", condition = in_mathzone }, t("\\neq")),
  s({ trig = ">=", snippetType = "autosnippet", condition = in_mathzone }, t("\\geq")),
  s({ trig = "<=", snippetType = "autosnippet", condition = in_mathzone }, t("\\leq")),
  s({ trig = ">>", snippetType = "autosnippet", condition = in_mathzone }, t("\\gg")),
  s({ trig = "<<", snippetType = "autosnippet", condition = in_mathzone }, t("\\ll")),
  s({ trig = "simm", snippetType = "autosnippet", condition = in_mathzone }, t("\\sim")),
  s({ trig = "sim=", snippetType = "autosnippet", condition = in_mathzone }, t("\\simeq")),
  s({ trig = "prop", snippetType = "autosnippet", condition = in_mathzone }, t("\\propto")),
  s({ trig = "<->", snippetType = "autosnippet", condition = in_mathzone }, t("\\leftrightarrow ")),
  s({ trig = "->", snippetType = "autosnippet", condition = in_mathzone }, t("\\to")),
  s({ trig = "!>", snippetType = "autosnippet", condition = in_mathzone }, t("\\mapsto")),
  s({ trig = "=>", snippetType = "autosnippet", condition = in_mathzone }, t("\\implies")),
  s({ trig = "=<", snippetType = "autosnippet", condition = in_mathzone }, t("\\impliedby")),
  s({ trig = "and", snippetType = "autosnippet", condition = in_mathzone }, t("\\cap")),
  s({ trig = "orr", snippetType = "autosnippet", condition = in_mathzone }, t("\\cup")),
  s({ trig = "inn", snippetType = "autosnippet", condition = in_mathzone }, t("\\in")),
  s({ trig = "notin", snippetType = "autosnippet", condition = in_mathzone }, t("\\not\\in")),
  s({ trig = "\\\\\\", snippetType = "autosnippet", condition = in_mathzone }, t("\\setminus")),
  s({ trig = "sub=", snippetType = "autosnippet", condition = in_mathzone }, t("\\subseteq")),
  s({ trig = "sup=", snippetType = "autosnippet", condition = in_mathzone }, t("\\supseteq")),
  s({ trig = "eset", snippetType = "autosnippet", condition = in_mathzone }, t("\\emptyset")),
  s({ trig = "set", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\{ <> \\}<>", { i(1), i(2) })),
  s({ trig = "mset", snippetType = "autosnippet", condition = in_mathzone }, t("\\setminus")),
  s({ trig = "exists", snippetType = "autosnippet", priority = 1000, condition = in_mathzone }, t("\\exists")),
  s({ trig = "LL", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathcal{L}")),
  s({ trig = "HH", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathcal{H}")),
  s({ trig = "CC", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathbb{C}")),
  s({ trig = "RR", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathbb{R}")),
  s({ trig = "ZZ", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathbb{Z}")),
  s({ trig = "NN", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathbb{N}")),
  s({ trig = "PP", snippetType = "autosnippet", condition = in_mathzone }, t("\\mathcal{P}")),

  -- Spaces/backslashes
  s({ trig = "   ", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, t(" \\quad ")),
  s(
    {
      trig = "([^\\])(" .. greek .. ")",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end)
  ),
  s(
    {
      trig = "([^\\])(" .. symbol .. ")",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. "|" .. more_symbols .. ")([A-Za-z])",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\" .. snip.captures[1] .. " " .. snip.captures[2]
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") sr",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\" .. snip.captures[1] .. "^{2}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") cb",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\" .. snip.captures[1] .. "^{3}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") rd",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    fmta("\\<>^{<>}<>", { f(function(_, snip)
      return snip.captures[1]
    end), i(1), i(2) })
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") hat",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\hat{\\" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") dot",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\dot{\\" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") bar",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\bar{\\" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") vec",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\vec{\\" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") tilde",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\tilde{\\" .. snip.captures[1] .. "}"
    end)
  ),
  s(
    {
      trig = "\\(" .. greek .. "|" .. symbol .. ") und",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\underline{\\" .. snip.captures[1] .. "}"
    end)
  ),

  -- Derivatives and integrals
  s(
    { trig = "par", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\frac{ \\partial <> }{ \\partial <> } <>", { i(1, "y"), i(2, "x"), i(3) })
  ),
  s(
    {
      trig = "pa([A-Za-z])([A-Za-z])",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\frac{ \\partial " .. snip.captures[1] .. " }{ \\partial " .. snip.captures[2] .. " } "
    end)
  ),
  s({ trig = "ddt", snippetType = "autosnippet", condition = in_mathzone }, t("\\frac{d}{dt} ")),
  s(
    {
      trig = "([^\\])int",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      priority = -1,
      condition = in_mathzone,
    },
    f(function(_, snip)
      return snip.captures[1] .. "\\int"
    end)
  ),
  s(
    { trig = "\\int", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\int <> \\, d<> <>", { i(1), i(2, "x"), i(3) })
  ),
  s(
    { trig = "dint", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\int_{<>}^{<>} <> \\, d<> <>", { i(1, "0"), i(2, "1"), i(3), i(4, "x"), i(5) })
  ),
  s({ trig = "oint", snippetType = "autosnippet", condition = in_mathzone }, t("\\oint")),
  s(
    { trig = "cint", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\int_{<>} <> \\mathop{d<>} <>", { i(1, "C"), i(2), i(3, "z"), i(4) })
  ),
  s({ trig = "iint", snippetType = "autosnippet", condition = in_mathzone }, t("\\iint")),
  s({ trig = "iiint", snippetType = "autosnippet", condition = in_mathzone }, t("\\iiint")),
  s(
    { trig = "oinf", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\int_{0}^{\\infty} <> \\, d<> <>", { i(1), i(2, "x"), i(3) })
  ),
  s(
    { trig = "infi", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\int_{-\\infty}^{\\infty} <> \\, d<> <>", { i(1), i(2, "x"), i(3) })
  ),

  -- Trig
  s(
    {
      trig = "([^\\])(arcsin|sin|arccos|cos|arctan|tan|csc|sec|cot)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end)
  ),
  s(
    {
      trig = "\\(arcsin|sin|arccos|cos|arctan|tan|csc|sec|cot)([A-Za-gi-z])",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\" .. snip.captures[1] .. " " .. snip.captures[2]
    end)
  ),
  s(
    {
      trig = "\\(sinh|cosh|tanh|coth)([A-Za-z])",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      condition = in_mathzone,
    },
    f(function(_, snip)
      return "\\" .. snip.captures[1] .. " " .. snip.captures[2]
    end)
  ),

  -- Physics / QM / chemistry
  s({ trig = "kbt", snippetType = "autosnippet", condition = in_mathzone }, t("k_{B}T")),
  s({ trig = "msun", snippetType = "autosnippet", condition = in_mathzone }, t("M_{\\odot}")),
  s({ trig = "dag", snippetType = "autosnippet", condition = in_mathzone }, t("^{\\dagger}")),
  s({ trig = "o+", snippetType = "autosnippet", condition = in_mathzone }, t("\\oplus ")),
  s({ trig = "ox", snippetType = "autosnippet", condition = in_mathzone }, t("\\otimes ")),
  s({ trig = "bra", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\bra{<>} <>", { i(1), i(2) })),
  s({ trig = "ket", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\ket{<>} <>", { i(1), i(2) })),
  s(
    { trig = "brk", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\braket{ <> | <> } <>", { i(1), i(2), i(3) })
  ),
  s(
    { trig = "outer", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\ket{<>} \\bra{<>} <>", { i(1, "\\psi"), rep(1), i(2) })
  ),
  s({ trig = "pu", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\pu{ <> }", { i(1) })),
  s({ trig = "cee", snippetType = "autosnippet", condition = in_mathzone }, fmta("\\ce{ <> }", { i(1) })),
  s({ trig = "he4", snippetType = "autosnippet", condition = in_mathzone }, t("{}^{4}_{2}He ")),
  s({ trig = "he3", snippetType = "autosnippet", condition = in_mathzone }, t("{}^{3}_{2}He ")),
  s(
    { trig = "iso", snippetType = "autosnippet", condition = in_mathzone },
    fmta("{}^{<>}_{<>}<>", { i(1, "4"), i(2, "2"), i(3, "He") })
  ),

  -- Environments
  s(
    { trig = "pmat", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{pmatrix}
<>
\end{pmatrix}]],
      { i(1) }
    )
  ),
  s(
    { trig = "bmat", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{bmatrix}
<>
\end{bmatrix}]],
      { i(1) }
    )
  ),
  s(
    { trig = "Bmat", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{Bmatrix}
<>
\end{Bmatrix}]],
      { i(1) }
    )
  ),
  s(
    { trig = "vmat", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{vmatrix}
<>
\end{vmatrix}]],
      { i(1) }
    )
  ),
  s(
    { trig = "Vmat", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{Vmatrix}
<>
\end{Vmatrix}]],
      { i(1) }
    )
  ),
  s(
    { trig = "matrix", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{matrix}
<>
\end{matrix}]],
      { i(1) }
    )
  ),
  s(
    { trig = "cases", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{cases}
<>
\end{cases}]],
      { i(1) }
    )
  ),
  s(
    { trig = "align", snippetType = "autosnippet", condition = in_text },
    fmta(
      [[\begin{align}
<>
\end{align}]],
      { i(1) }
    )
  ),
  s(
    { trig = "array", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{array}
<>
\end{array}]],
      { i(1) }
    )
  ),
  s(
    { trig = "eqnarr", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      [[\begin{eqnarray}
<>
\end{eqnarray}]],
      { i(1) }
    )
  ),

  -- Brackets
  s(
    { trig = "avg", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\langle <> \\rangle <>", { i(1), i(2) })
  ),
  s(
    { trig = "norm", snippetType = "autosnippet", priority = 1000, condition = in_mathzone },
    fmta("\\lvert <> \\rvert <>", { i(1), i(2) })
  ),
  s(
    { trig = "Norm", snippetType = "autosnippet", priority = 1000, condition = in_mathzone },
    fmta("\\lVert <> \\rVert <>", { i(1), i(2) })
  ),
  s(
    { trig = "ceil", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\lceil <> \\rceil <>", { i(1), i(2) })
  ),
  s(
    { trig = "floor", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\lfloor <> \\rfloor <>", { i(1), i(2) })
  ),
  s({ trig = "(", snippetType = "autosnippet", condition = in_mathzone }, fmta("(<>)<>", { i(1), i(2) })),
  s({ trig = "{", snippetType = "autosnippet", condition = in_mathzone }, fmta("{<>}<>", { i(1), i(2) })),
  s({ trig = "[", snippetType = "autosnippet", condition = in_mathzone }, fmta("[<>]<>", { i(1), i(2) })),
  s(
    { trig = "lr(", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\left( <> \\right) <>", { i(1), i(2) })
  ),
  s(
    { trig = "lr{", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\left\\{ <> \\right\\} <>", { i(1), i(2) })
  ),
  s(
    { trig = "lr[", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\left[ <> \\right] <>", { i(1), i(2) })
  ),
  s(
    { trig = "lr|", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\left| <> \\right| <>", { i(1), i(2) })
  ),
  s(
    { trig = "lra", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\left\\langle <> \\right\\rangle <>", { i(1), i(2) })
  ),

  -- Series, misc, custom
  s(
    { trig = "powsum", snippetType = "autosnippet", condition = in_mathzone },
    fmta("\\sum_{<> = <>}^{<>} <> <>", { i(1, "n"), i(2, "0"), i(3, "\\infty"), i(4, "a_n (z-z_0)^n"), i(5) })
  ),
  s({ trig = "orng", snippetType = "autosnippet", condition = in_mathzone }, t("\\color{orange}")),
  s(
    { trig = "tayl", snippetType = "autosnippet", condition = in_mathzone },
    fmta(
      "<>(<> + <>) = <>(<>) + <>'(<>)<> + <>''(<>) \\frac{<>^{2}}{2!} + \\dots<>",
      { i(1, "f"), i(2, "x"), i(3, "h"), rep(1), rep(2), rep(1), rep(2), rep(3), rep(1), rep(2), rep(3), i(4) }
    )
  ),
  s(
    { trig = "iden(%d)", regTrig = true, wordTrig = false, snippetType = "autosnippet", condition = in_mathzone },
    d(1, identity_matrix, {})
  ),
}

local regular = {
  -- Visual style manual snippets for selected text / placeholders
  s({ trig = "U", condition = in_mathzone }, fmta("\\underbrace{ <> }_{ <> }", { i(1), i(2) })),
  s({ trig = "O", condition = in_mathzone }, fmta("\\overbrace{ <> }^{ <> }", { i(1), i(2) })),
  s({ trig = "B", condition = in_mathzone }, fmta("\\underset{ <> }{ <> }", { i(1), i(2) })),
  s({ trig = "C", condition = in_mathzone }, fmta("\\cancel{ <> }", { i(1) })),
  s({ trig = "K", condition = in_mathzone }, fmta("\\cancelto{ <> }{ <> }", { i(1), i(2) })),
  s({ trig = "S", condition = in_mathzone }, fmta("\\sqrt{ <> }", { i(1) })),

  -- Inline matrix single-line variants kept as manual snippets
  s({ trig = "pmat1", condition = in_mathzone }, fmta("\\begin{pmatrix}<>\\end{pmatrix}", { i(1) })),
  s({ trig = "bmat1", condition = in_mathzone }, fmta("\\begin{bmatrix}<>\\end{bmatrix}", { i(1) })),
  s({ trig = "Bmat1", condition = in_mathzone }, fmta("\\begin{Bmatrix}<>\\end{Bmatrix}", { i(1) })),
  s({ trig = "vmat1", condition = in_mathzone }, fmta("\\begin{vmatrix}<>\\end{vmatrix}", { i(1) })),
  s({ trig = "Vmat1", condition = in_mathzone }, fmta("\\begin{Vmatrix}<>\\end{Vmatrix}", { i(1) })),
  s({ trig = "matrix1", condition = in_mathzone }, fmta("\\begin{matrix}<>\\end{matrix}", { i(1) })),
}

ls.add_snippets("tex", regular)
ls.add_snippets("plaintex", regular)
ls.add_snippets("latex", regular)
ls.add_snippets("tex", autos, { type = "autosnippets" })
ls.add_snippets("plaintex", autos, { type = "autosnippets" })
ls.add_snippets("latex", autos, { type = "autosnippets" })

return regular
