return {
  {
    "kylechui/nvim-surround",
    opts = {
      -- Defaults (we use ß instead of s to keep flash):
      --  insert = "<C-g>s",         -- ?
      --  insert_line = "<C-g>S",    -- ?
      --  normal = "ys",             -- Surround movement region
      --  normal_cur = "yss",        -- Surround whole line
      --  normal_line = "yS",        -- Surround movement region, pad with \n
      --  normal_cur_line = "ySS",   -- Surround whole line, on new lines
      --  visual = "S",              -- Sourround selection
      --  visual_line = "gS",        -- Surround selection, pad with \n
      --  delete = "ds",             -- Delete inner most surrouding
      --  change = "cs",             -- Change inner/previous sourrounding
      --  change_line = "cS",        -- Change inner/previous, pad with \n
      keymaps = {
        insert = false,
        insert_line = false,
        normal = "ß",
        normal_cur = "ßß", -- Use double ßß to be consistent with "dd", etc.
        normal_line = "gßß", -- (Consider visual mode ßß)
        normal_cur_line = "gß", -- (Consider visual-line mode ß)
        visual = "ß",
        visual_line = "ßß",
        delete = "dß",
        change = "cß",
        change_line = "cßß",
      },
      -- surrounds =     -- Defines surround keys and behavior
      -- aliases =       -- Defines aliases
      -- highlight =     -- Defines highlight behavior
      -- move_cursor =   -- Defines cursor behavior
      -- indent_lines =  -- Defines line indentation behavior
    },
  },
}
