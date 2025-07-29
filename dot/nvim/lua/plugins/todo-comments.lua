return {
  -- NOTE: Expands on default config without overwriting it. :h todo-comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        DEPRECATED = { icon = " ", color = "deprecated", alt = { "RETIRED" } },
        CLEANUP = { icon = "󰃢 ", color = "deprecated", alt = { "CLEAN" } },
        -- Where we want to continue immediately next time
        CONTINUE = { icon = " ", color = "pause", alt = { "NEXT" } },
        -- Where we stopped to come back later
        PAUSE = { icon = " ", color = "pause", alt = { "LATER", "BREAK" } },
        -- Stopped to work on something else
        STOPPED = { icon = " ", color = "pause", alt = { "STOP", "HALT", "WAIT" } },
      },
      merge_keywords = true, -- when true, custom keywords will be merged with the defaults
      colors = {
        deprecated = { "DiagnosticUnnecessary", "#ff5000" },
        pause = { "DiagnosticOk", "#40C020" },
      },
    },
  },
}
