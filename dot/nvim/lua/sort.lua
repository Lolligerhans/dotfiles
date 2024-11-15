-- Commands to sort paragraphs (like functions).

-- NOTE: The keymaps.lua defines paragraph marking

local function mark_paragraph()
  vim.cmd([[
    s/^/ẞp
  ]])
end

local function mark_sort()
  vim.cmd([[
    normal iẞm
    normal h
  ]])
end

local function mark_lines()
  vim.cmd([[
    ?ẞstart?+1,/ẞend/-1s/$/ẞl
  ]])
end

local function replace_newlines()
  vim.cmd([[
    ?ẞstart?,/ẞend/-2s/\n//g
  ]])
end

local function replace_paragraphs()
  vim.cmd([[
    ?ẞstart?,/ẞend/-1s/ẞp/\r/g
  ]])
end

local function sort_markers()
  vim.cmd([[
    ?ẞstart?+1,/ẞend/-1sort /ẞm/
  ]])
end

local function remove_trailing_lines()
  vim.cmd([[
    ?ẞstart?+1,/ẞend/-1s/ẞl$//
  ]])
end

local function replace_lines()
  vim.cmd([[
    ?ẞstart?+1,/ẞend/-1s/ẞl/\r/g
  ]])
end

local function remove_marks()
  vim.cmd([[
    ?ẞstart?+1,/ẞend/-1s/ẞm//g
  ]])
end

local function remove_range()
  vim.cmd([[
    g/^ẞ\(start\|end\)$/d
  ]])
end

-- ── Interface ──────────────────────────────────────────────

local M = {}
M.mark_paragraph = mark_paragraph
M.mark_sort = mark_sort
M.sort = function()
  -- M.mark_range()
  -- M.mark_paragraph()
  -- M.mark_sort()
  -- M.mark_lines()
  mark_lines()
  replace_newlines()
  replace_paragraphs()
  sort_markers()
  remove_trailing_lines()
  replace_lines()
  remove_marks()
  remove_range()
end

return M
