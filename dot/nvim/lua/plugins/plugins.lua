--
-- distributed to other files. (the original example.lua is still there but has
-- no effect).

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- TODO Check if we like the default options

-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {

  -- ╭───────────────────────────────────────────────────────────╮
  -- │ Configure LazyVim plugins                                 │
  -- ╰───────────────────────────────────────────────────────────╯

  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        -- mode = "tabs",
        separator_style = "slant",
      },
    },
    -- enabled = false,
  },

  -- add gruvbox
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
      -- "retrobox",
      -- "gruvbox",
      -- "tokyonight-night",
      -- "onedark",
      -- "everforest",
      -- "nightfox",
      -- {
      --   "hrsh7th/nvim-cmp",
      --   dependencies = { "hrsh7th/cmp-emoji" },
      --   ---@param opts cmp.ConfigSchema
      --   opts = function(_, opts)
      --     table.insert(opts.sources, { name = "emoji" })
      --   end,
      -- },
    },
  },

  -- :LazyExtras
  -- {
  --   "junegunn/fzf",
  -- },

  -- {
  --   "ibhagwan/fzf-lua",
  --   keys = function() return {} end,  -- disable all key maps (we make our own for now)
  --   opts =
  --   {
  --     build = "./install --bin",
  --     -- require('fzf-lua').setup({ fzf.install() }),
  --   },
  -- },

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- -- disable trouble
  -- { "folke/trouble.nvim",                             enabled = false

  -- -- override nvim-cmp and add cmp-emoji
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = { "hrsh7th/cmp-emoji" },
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     table.insert(opts.sources, { name = "emoji" })
  --   end,
  -- },

  -- -- change some telescope options and a keymap to browse plugin files
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   keys = {
  --     -- add a keymap to browse plugin files
  --     -- stylua: ignore
  --     {
  --       "<leader>fp",
  --       function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
  --       desc = "Find Plugin File",
  --     },
  --   },
  --   -- change some options
  --   -- opts = {
  --   --   defaults = {
  --   --     layout_strategy = "horizontal",
  --   --     layout_config = { prompt_position = "top" },
  --   --     sorting_strategy = "ascending",
  --   --     winblend = 0,
  --   --   },
  --   -- },
  -- },

  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
      },
      inlay_hints = { enabled = false },
    },
  },

  -- -- add tsserver and setup with typescript.nvim instead of lspconfig
  -- -- TODO: No longer working
  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = {
  --     "jose-elias-alvarez/typescript.nvim",
  --     init = function()
  --       require("lazyvim.util").lsp.on_attach(function(_, buffer)
  --         -- stylua: ignore
  --         vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
  --         vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
  --       end)
  --     end,
  --   },
  --   ---@class PluginLspOpts
  --   opts = {
  --     ---@type lspconfig.options
  --     servers = {
  --       -- tsserver will be automatically installed with mason and loaded with lspconfig
  --       tsserver = {},
  --     },
  --     -- you can do any additional lsp server setup here
  --     -- return true if you don't want this server to be setup with lspconfig
  --     ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
  --     setup = {
  --       -- example to setup with typescript.nvim
  --       tsserver = function(_, opts)
  --         require("typescript").setup({ server = opts })
  --         return true
  --       end,
  --       -- Specify * to use this function as a fallback for any server
  --       -- ["*"] = function(server, opts) end,
  --     },
  --   },
  -- },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "cpp",
        "bash",
        "css",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        -- "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      })
    end,
  },

  -- -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
  -- -- would overwrite `ensure_installed` with the new value.
  -- -- If you'd rather extend the default config, use the code below instead:
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = function(_, opts)
  --     -- add tsx and treesitter
  --     vim.list_extend(opts.ensure_installed, {
  --       "tsx",
  --       "typescript",
  --     })
  --   end,
  -- },

  -- -- the opts function can also be used to change the default opts:
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   opts = function(_, opts)
  --     opts.theme = "gruvbox"
  --     -- table.insert(opts.sections.lualine_x, "😄")
  --   end,
  -- },

  -- or you can return new options to override all the defaults
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    -- opts = {
    --   theme = "gruvbox"
    --   -- theme = "onedark"
    -- },
  },

  -- use mini.starter instead of alpha
  -- { import = "lazyvim.plugins.extras.ui.mini-starter" },

  -- add any tools you want to have installed below
  {
    "mason-org/mason.nvim",
    opts = {
      -- TODO: Not sure what this does. I think these need to be mirrored in
      --       nvim-lspconfig or something?
      ensure_installed = {
        "cpptools",
        "clangd",
        "clang-format",
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },

  -- {
  --   "folke/snacks.nvim",
  --   opts = { dashboard = { enabled = false } },
  -- },

  {
    "folke/snacks.nvim",
    ---@param _ any
    ---@param opts type snacks.Config
    opts = function(_, opts)
      opts.dashboard.preset.header = require("plugins/util/logo").random("pieces")
      table.insert(
        opts.dashboard.preset.keys,
        { icon = " ", key = "h", desc = "LazyHealth", action = ":LazyHealth" }
      )
    end,
    -- opts = {
    --   dashboard = {},
    -- },
  },

  -- ╭───────────────────────────────────────────────────────────────────────────╮
  -- │ Our own                                                                   │
  -- ╰───────────────────────────────────────────────────────────────────────────╯

  -- {
  --   "NeogitOrg/neogit",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim", -- required
  --     "sindrets/diffview.nvim", -- optional - Diff integration
  --
  --     -- Only one of these is needed.
  --     -- "nvim-telescope/telescope.nvim", -- optional
  --     "ibhagwan/fzf-lua", -- optional
  --     -- "echasnovski/mini.pick",         -- optional
  --   },
  --   config = true
  -- },

  {
    -- For easily making boxes in comments
    "LudoPinelli/comment-box.nvim",
    opts = {
      -- box=78, doc=80 for wide boxes
      box_width = 62,
      doc_width = 64, -- Used for centering
    },
  },

  {
    "preservim/tagbar",
  },

  -- List:
  -- https://github.com/Shatur/neovim-session-manager
}
