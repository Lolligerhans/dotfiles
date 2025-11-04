-- HACK: Hotfix for broken bufferline plugin. Not sure what's wring. There's
--       a PR pending: https://github.com/LazyVim/LazyVim/pull/6354. When the
--       problem is resolved this file can be removed. Test be deleting this
--       file and starting NeoVim. When no error occurs it is probably fine.

return {
  {
    "catppuccin/nvim",
    opts = function(_, opts)
      local module = require("catppuccin.groups.integrations.bufferline")
      if module then
        module.get = module.get or module.get_theme
      else
        print("Could not hotfix bufferline integration. Sad!")
      end
      return opts
    end,
  },
}
