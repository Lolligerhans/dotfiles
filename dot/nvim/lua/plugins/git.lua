return {
  {
    "tpope/vim-fugitive",
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    -- LazyVim seems to overwrite the default sign symbols with something worse.
    -- Maybe a compatibility thing? We delete the LazyVim config, using the
    -- plugin default instead.
    opts = function(_, opts)
      opts.signs = nil
      opts.signs_staged = nil
    end,
  },
}
