-- functions.lua
--
-- Define vim functions delegating to lua equivalents. No need to load long
-- functions on startup. And no need to call with
--    :lua Func()
-- but simpler as
--    :Func

-- vim.cmd([[echo "functions.lua: Now loading"]])

vim.api.nvim_create_user_command("Dig", [[lua require("functions/digraphs").dig()]], {})
vim.api.nvim_create_user_command("Put", function(args)
  require("functions/digraphs").put(args["args"])
end, { nargs = "?" })
