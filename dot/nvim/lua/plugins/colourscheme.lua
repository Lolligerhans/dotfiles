-- https://github.com/lifepillar/vim-gruvbox8/tree/neovim
-- retrobox
-- catppuccin
-- https://github.com/morhetz/gruvbox

return {
  -- { "morhetz/gruvbox" },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
    opts = ...,
  },
  {
    "navarasu/onedark.nvim",
    opts = { style = "darker" },
  },
  {
    "https://github.com/ayu-theme/ayu-vim",
  },
  -- { "sainnhe/everforest" },
  -- { "tiagovla/tokyodark.nvim" },
  -- { "EdenEast/nightfox.nvim" },
}
