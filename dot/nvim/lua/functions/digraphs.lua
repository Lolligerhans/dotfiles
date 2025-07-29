-- vim.cmd([[echo "Now loading digraphs.lua"]])

local function dig()
  vim.cmd([[tabnew|pu=execute(':digraph!')]])
end

-- local function put(command)
--   vim.cmd([[norm :enew\|pu=execute(:]] .. command .. ")")
-- end

local M = {}
M.dig = dig

return M
