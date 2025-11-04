return {

  -- Alternating insert/normal mode can be annoying:
  --  - tables blink left/right as elements adding characters are toggled
  --  - lines move up/down as elements adding lines are toggled
  -- Enable markdown render in insert mode to simply keep it on. We toggle it
  -- manually if we want to hide it using "<leader>um".
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      render_modes = { "n", "c", "t", "i" },
      -- We do not have utftex and latex2text installed. render-markdown.nvim
      -- complains in checkhealth and advises to disable it. We don't need it so
      -- we just disable it.
      latex = { enabled = false },
    },
  },
}
