return {
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },

    opts = {
      btags = {
        fzf_opts = {
          ["--no-hscroll"] = true,
        },
      },
      tags = {
        fzf_opts = {
          ["--no-hscroll"] = true,
          -- ["--wrap"] = true,
        },
      },
    },

    keys = {
      {
        -- Substitutes the LazyVim default which does file search only
        "<leader><leader>",
        "<cmd>FzfLua global<cr>",
        mode = "n",
        remap = false,
        desc = "Find anything",
      },

      -- NOTE: This was a test that is now part of the regular keymaps
      -- {
      --   "<localleader>f",
      --   function()
      --     require("fzf-lua").tags({ fzf_opts = { ["--no-hscroll"] = true } })
      --   end,
      --   mode = "n",
      --   remap = false,
      --   desc = "Test hscrolling",
      -- },
    },

    -- opts = {
    --   actions = {
    --     files = {
    --
    --       -- -- FIXME: Does not work. Because we call require manually and run the
    --       -- --        default config thereby?
    --       -- ["ctrl-t"] = require("fzf-lua").actions.file_tabedit,
    --
    --       -- ["ctrl-t"] = function(...)
    --       --   local args = { ... }
    --       --   return require("fzf-lua").actions.file_tabedit(unpack(args))
    --       -- end,
    --
    --     },
    --   },
    -- },

    -- opts   = fzf_options,

    -- keys = function() return { {} } end,
    -- config = function()
    --   -- calling `setup` is optional for customization
    --   require("fzf-lua").setup({
    --     "default",
    --     -- Prevent default layout that reverse the order
    --     fzf_opts = { ["--layout"] = false },
    --     -- previewer = "builtin", ??
    --   })
    --
    --   -- vim.cmd("FzfLua setup_fzfvim_cmds")
    -- end,
  },
}
