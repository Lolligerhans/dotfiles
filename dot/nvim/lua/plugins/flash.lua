return {
  {
    "folke/flash.nvim",
    -- opts = function(_, opts)
    --   print("Remote Op:")
    --   print(opts.modes.treesitter_search.remote_op)
    --   opts.modes.treesitter_search.remote_op = { restore = true, motion = true }
    --   return opts
    -- end,
    opts = {
      modes = {

        search = {
          -- Causes jump marks to appear during live search
          enabled = true,
        },

        treesitter_search = {
          -- Causes the cursor to return to original position after
          -- treesitter-seaerch remote action, like 'yR'.
          remote_op = { restore = true, motion = true },
        },
      },
    },
  },
}
