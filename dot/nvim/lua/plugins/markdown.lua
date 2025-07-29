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
    },
  },
}
