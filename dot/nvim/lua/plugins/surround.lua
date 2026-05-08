local enable_surround = true

return {
  {
    "kylechui/nvim-surround",

    -- NOTE: I added 'lazy = false' after running into trouble with whatever the default would be. When resuming from
    --       the stored session, the plugin is not loaded by lazy.
    --
    -- My guess for what happens:
    --  - On first startup, Lazy sees keys = {}, being specified in the plugin configuration and knows to load the
    --    plugin.
    --    When loading a session, the keymaps are already generated, hence Lazy sees to reason to act. But because the
    --    plugin is not loaded, the mapping to <Plug>... is not valid as the plugin is not loaded.
    --
    -- Using 'lazy = false' instructs Lazy to always load the plugin on startup, even before its first use. Thus the
    -- mappings into the plugin functionality work. For other plugins, e.g. "fzf-lua", we map more idiomatically to
    -- 'require(plugin-name).function'. There the plugin is explicitly loaded on first use. Apparently the vimscript era
    -- "<Plug>" mappings do not work this way.
    lazy = false,

    init = function()
      -- Not sure if doing this in the global scope may be better. But since LazyVim explicitly collects initialization
      -- behaviour, and mentions this exact use case in the documentation, let's use it.
      vim.g.nvim_surround_no_mappings = enable_surround
    end,

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
      -- keymaps = {
      --   insert = false,
      --   insert_line = false,
      --   normal = "ß",
      --   normal_cur = "ßß", -- Use double ßß to be consistent with "dd", etc.
      --   normal_line = "gß", -- (Consider visual mode ßß)
      --   normal_cur_line = "gßß", -- (Consider visual-line mode ß)
      --   visual = "ß",
      --   visual_line = "ßß",
      --   delete = "dß",
      --   change = "cß",
      --   change_line = "cßß",
      -- },
      -- surrounds =     -- Defines surround keys and behavior
      -- aliases =       -- Defines aliases
      -- highlight =     -- Defines highlight behavior
      -- move_cursor =   -- Defines cursor behavior
      -- indent_lines =  -- Defines line indentation behavior
    },
    keys = {
      -- :h nvim-surround.migrating.v3_to_v4
      -- :h nvim-surround.keymaps
      -- All functions:
      --    ❌ Plug>(nvim-surround-insert)
      --    ❌ Plug>(nvim-surround-insert-line)
      --    ✅ <Plug>(nvim-surround-normal)
      --    ✅ <Plug>(nvim-surround-normal-cur)
      --    ✅ <Plug>(nvim-surround-normal-line)
      --    ✅ <Plug>(nvim-surround-normal-cur-line)
      --    ✅ <Plug>(nvim-surround-visual)
      --    ✅ <Plug>(nvim-surround-visual-line)
      --    ✅ <Plug>(nvim-surround-delete)
      --    ✅ <Plug>(nvim-surround-change)
      --    ✅ <Plug>(nvim-surround-change-line)
      { "ß", "<Plug>(nvim-surround-normal)", mode = "n", remap = false, desc = "ßurround" },
      { "ßß", "<Plug>(nvim-surround-normal-cur)", mode = "n", remap = false, desc = "ßurround line" },
      { "gß", "<Plug>(nvim-surround-normal-line)", mode = "n", remap = false, desc = "linewise ßurround" },
      { "gßß", "<Plug>(nvim-surround-normal-cur-line)", mode = "n", remap = false, desc = "linewise ßurround line" },
      { "ß", "<Plug>(nvim-surround-visual)", mode = "v", remap = false, desc = "ßurround" },
      { "ßß", "<Plug>(nvim-surround-visual-line)", mode = "v", remap = false, desc = "linewise ßurround" },
      { "dß", "<Plug>(nvim-surround-delete)", mode = "n", remap = false, desc = "delete ßurrounding" },
      { "cß", "<Plug>(nvim-surround-change)", mode = "n", remap = false, desc = "change ßurrounding" },
      {
        "cßß",
        "<Plug>(nvim-surround-change-line)",
        mode = "n",
        remap = false,
        desc = "linewise change ßurrounding",
      },
    },
  },
}
