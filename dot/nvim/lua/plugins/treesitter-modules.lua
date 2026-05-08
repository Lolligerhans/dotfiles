-- local languages = { 'c', 'lua', 'rust' }
return {

  -- Previously, the TreeSitter plugin would come with more batteries-included behavior by implementing some utilities
  -- in the plugin itself. Like highlighting or incremental selection. The new versions no longer do. I believe
  -- LazyVim has essentially re-implemented most of this previous functionality using the treesitter API.
  --
  -- For the incremental selection, the pre-existing plugin 'flash' was used. Flash overlays ghost text as flags to
  -- indicate different and possibly overlapping sections. That works well for us in the regular search mode, but
  -- causes headaches for incremental selection.
  --
  -- This plugin is added specifically for the only purpose of bringing back incremental selection. That is why the
  -- remaining configuration is 'enabled = false':
  --      - fold
  --      - highlight
  --      - indent
  -- I believe LazyVim still provides these
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      -- Not sure if we need to provide 'ensure_installed' here. The nvim-treesitter plugin may do the work for us?
      -- Otherwise we will probably have to synchronize with the treesitter plugin.
      -- ensure_installed = languages,
      fold = { enable = false },
      highlight = { enable = false },
      indent = { enable = false },
      incremental_selection = {
        enable = true,
        -- set value to `false` to disable individual mapping
        -- node_decremental captures both node_incremental and scope_incremental
        keymaps = {
          -- Use same keys LazyVim did (does?)
          init_selection = "<C-Space>",
          node_incremental = "<C-Space>",
          -- For the flash version this keymap is not shown in :map for some reason. Maybe flash enters its own special
          -- mode?
          node_decremental = "<BS>",

          -- Scope seems too large so not using it for now
          -- scope_incremental = "",
        },
      },
    },

    -- Alternatively we could try to manually create key mappings. Because I got the alternative working sooner I am
    -- going to stick with that for now.
    -- keys = {
    --   {
    --     "<C-Space>",
    --     function()
    --       require("treesitter-modules").init_selectionend()
    --     end,
    --     mode = {
    --       "x",
    --       "o",
    --       "n",
    --     },
    --     remap = false,
    --     desc = "Increment selection",
    --   },
    -- },
  },
}
