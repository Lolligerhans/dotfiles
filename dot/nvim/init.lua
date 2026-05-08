-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- -- https://github.com/neovim/neovim/issues/27489
-- vim.notify(tostring(42))
-- vim.notify(tostring(vim.g.reload_exrc))
-- if vim.g.reload_exrc then
--   local contents = vim.secure.read(".nvim.lua")
--   if contents then
--     vim.notify("Loading exrc")
--     assert(loadstring(contents))()
--   else
--     vim.notify("Exrc not found")
--   end
-- else
--   vim.notify("Not reloading exrc")
-- end
