return {
  -- FIXME: Does nothing
  -- Try bringing back emojis for completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji", opts = { insert = true } })
    end,
  },
}
