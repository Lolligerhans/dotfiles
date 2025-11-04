-- vim.cmd([[echo "Now loading digraphs.lua"]])

local function dig()
  vim.cmd([[tabnew|pu=execute(':digraph!')]])
end

local function put(command)
  -- local command = args["args"]
  -- local str = args["args"] or nil
  vim.cmd([[tabnew|pu=execute(']] .. command .. [[')]])
end

-- local function put(command)
--   vim.cmd([[norm :enew\|pu=execute(:]] .. command .. ")")
-- end

local M = {}
M.dig = dig
M.put = put

return M
