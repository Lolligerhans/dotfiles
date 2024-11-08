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
return
{

  -- ╭───────────────────────────────────────────────────────────╮
  -- │ Configure LazyVim plugins                                 │
  -- ╰───────────────────────────────────────────────────────────╯

  -- {
  --   "akinsho/bufferline.nvim",
  --   opts = {
  --     options = {
  --       mode = "tabs",
  --     },
  --   },
  --   -- enabled = false,
  -- },

  -- add gruvbox
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme =
      -- "retrobox",
      -- "gruvbox",
      "catppuccin",
      -- "tokyonight-night",
      -- "onedark",
      -- "everforest",
      -- "nightfox",
      {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-emoji" },
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
          table.insert(opts.sources, { name = "emoji" })
        end,
      },
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

  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- keys = function() return { {} } end,
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({
        "default",
        -- Prevent default layout that reverse the order
        fzf_opts = { ['--layout'] = false },
        -- previewer = "builtin", ??
      })

      -- vim.cmd("FzfLua setup_fzfvim_cmds")
    end
  },

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- -- disable trouble
  -- { "folke/trouble.nvim",                             enabled = false

  -- override nvim-cmp and add cmp-emoji
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },

  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- change some options
    -- opts = {
    --   defaults = {
    --     layout_strategy = "horizontal",
    --     layout_config = { prompt_position = "top" },
    --     sorting_strategy = "ascending",
    --     winblend = 0,
    --   },
    -- },
  },

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

  -- add tsserver and setup with typescript.nvim instead of lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {},
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
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

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },

  -- Is there a more distinct way than repeating the entire config to change
  -- the logo?
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    enabled = true,
    init = false,
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      --   local logo = [[
      --      ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
      --      ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
      --      ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
      --      ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
      --      ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
      --      ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
      -- ]]
      local logo = require("plugins/util/logo").random("pieces")

      -- stylua: ignore
      dashboard.section.header.val = vim.split(logo, "\n")
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", LazyVim.pick()),
        dashboard.button("n", " " .. " New file", [[<cmd> ene <BAR> startinsert <cr>]]),
        dashboard.button("r", " " .. " Recent files", LazyVim.pick("oldfiles")),
        dashboard.button("g", " " .. " Find text", LazyVim.pick("live_grep")),
        dashboard.button("c", " " .. " Config", LazyVim.pick.config_files()),
        dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
        dashboard.button("x", " " .. " Lazy Extras", "<cmd> LazyExtras <cr>"),
        dashboard.button("l", "󰒲 " .. " Lazy", "<cmd> Lazy <cr>"),
        dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          once = true,
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded "
              .. stats.loaded
              .. "/"
              .. stats.count
              .. " plugins in "
              .. ms
              .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- ╭───────────────────────────────────────────────────────────────────────────╮
  -- │ Our own                                                                   │
  -- ╰───────────────────────────────────────────────────────────────────────────╯

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

  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'topline',         -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20,     -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
  },

  {
    -- This plugin maps normal mode "gS" to split/join arguments over lines
    "FooSoft/vim-argwrap",
  },

  {
    "kylechui/nvim-surround",
    opts = {
      -- Defaults (we use ß instead of s to keep flash):
      --  insert = "<C-g>s",         -- ?
      --  insert_line = "<C-g>S",    -- ?
      --  normal = "ys",             -- Surround movement region
      --  normal_cur = "yss",        -- Surround whole line
      --  normal_line = "yS",        -- Surround movement region pad with \n
      --  normal_cur_line = "ySS",   -- Surround whole line, on new lines
      --  visual = "S",              -- Sourround selection
      --  visual_line = "gS",        -- Surround selection, pad with \n
      --  delete = "ds",             -- Delete inner most surrouding
      --  change = "cs",             -- Change inner/previous sourrounding
      --  change_line = "cS",        -- Change inner/previous, pad with \n
      keymaps = {
        insert = false,
        insert_line = false,
        normal = false,          -- Use visual mode ß. Changes '<,'>.
        normal_cur = "gßß",      -- Use double to be consistent with "dd", "cc", etc.
        normal_line = "gß",
        normal_cur_line = false, -- Use visual mode ßß. Changes '<'>.
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

  -- List:
  -- https://github.com/Shatur/neovim-session-manager

}
