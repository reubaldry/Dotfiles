return {
  {
    'L3MON4D3/LuaSnip',
    config = function(_, opts)
      local ls = require('luasnip')
      if opts then
        ls.config.set_config(opts)
      end

      ls.config.setup({
        enable_autosnippets = true,
        updateevents = 'TextChanged,TextChangedI',
        delete_check_events = 'TextChanged',
        ext_opts = {
          [require('luasnip.util.types').choiceNode] = {
            active = {
              virt_text = { { '<- choice', 'Comment' } },
            },
          },
        },
      })

      require('luasnip.loaders.from_lua').lazy_load({
        paths = { vim.fn.stdpath('config') .. '/lua/snippets' },
      })
    end,
  },
}
