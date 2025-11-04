-- Mason has a new version that breaks something in LazyVim.
-- https://github.com/LazyVim/LazyVim/issues/6039
--
-- Prevent Mason from being upgraded to major release 2.x.y (which is
-- incompatible currently).
-- HACK: Remove when and if these things change. Maybe test every other month.
return {
  { "mason-org/mason.nvim", version = "^1.0.0" },
  { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },

  -- FIXME: Not sure if this addition does anything or was ever needed, but now
  --        I am too scared to remove it. When this whole debacle is resolved
  --        and newest version of LazyVim and Mason work together, this can
  --        probably go too.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          mason = false,
        },
      },
    },
  },
}
