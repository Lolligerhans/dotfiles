return {
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },

    opts = {

      -- BUG: I believe when I turn the default no-hscroll option on, some of
      --      the fallbacks for lsp_workspace_symbols are no longer included.
      --      Not sure what is going on but surprising.
      -- btags = {
      --   fzf_opts = {
      --     ["--no-hscroll"] = true,
      --   },
      -- },

      tags = {
        fzf_opts = {
          ["--no-hscroll"] = true,
          -- ["--wrap"] = true,
        },
      },
      lsp_workspace_symbols = {
        fzf_opts = {
          -- I think when no matches are found it has a fallback including file
          -- paths. The fallback ignores this option, maybe we would need to set
          -- it for the fallback'd-to command?
          ["--no-hscroll"] = true,
        },
      },
      lsp_live_workspace_symbols = {
        fzf_opts = {
          ["--no-hscroll"] = true,
        },
      },
      lsp_document_symbols = {
        fzf_opts = {
          ["--no-hscroll"] = true,
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
