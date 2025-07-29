-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Deletions                                                                 │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- Disable autoformat for lua files
-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = { "lua" },
--   callback = function()
--     vim.b.autoformat = false -- .b == buffer scope
--   end,
-- })

-- " custom filetypes (we snatched this from :help tagbar
--   augroup filetypedetect
--     au! BufRead,BufNewFile *.inc setfiletype cpp
--     au! BufRead,BufNewFile *.test setfiletype cpp
--   augroup END
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "inc", "test" },
  callback = function()
    vim.filetype:set("cpp")
  end,
})

-- Thwart ftplugins overwriting our formatoptions
vim.api.nvim_create_autocmd("FileType", { command = "set formatoptions-=o" })

-- Start :terminal buffers in insert mode
-- autocmd TermOpen * startinsert
vim.api.nvim_create_autocmd("TermOpen", { pattern = "term://*", command = "startinsert" })
