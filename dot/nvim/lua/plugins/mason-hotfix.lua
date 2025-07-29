-- Mason has a new version that breaks something in LazyVim.
-- https://github.com/LazyVim/LazyVim/issues/6039
--
-- Prevent Mason from being upgraded to major release 2.x.y (which is
-- incompatible currently).
return {
  { "mason-org/mason.nvim", version = "^1.0.0" },
  { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
}
-- HACK: Remove when and if these things change. Maybe test every other month.
