-- Commands and functions we want to keep out of keymaps.lua. But presumably we
-- will often use these things by creating a mapping there.

--TODO: Rename to "commands" or "functions"

function DiffToggle()
  if vim.opt.diff:get() then
    vim.cmd([[diffoff]])
  else
    vim.cmd([[diffthis]])
  end
end

-- HACK: Not sure if commands are supposed to be created this way in lazyvim
return {

  vim.api.nvim_create_user_command(
    -- Command generating ctags
    "MakeTagsSafe",
    "!touch .ctagsignore && ctags -R --c++-kinds=+p --fields=+iaS --extras=+q",
    {}
  ),

  vim.api.nvim_create_user_command(
    -- Command generating ctags
    "MakeTags",
    "!rm tags || true && touch .ctagsignore && ctags -R --c++-kinds=+p --fields=+iaS --extras=+q",
    {}
  ),

  vim.api.nvim_create_user_command(
    -- Remove trailing whitespace
    "Rtw",
    "%s/\\s\\+$//c",
    {}
  ),

  vim.api.nvim_create_user_command(
    -- Remove ANSII (colour and other) escape codes. Escape character is 0x1b.
    "Unsi",
    "%s/[[:escape:]].\\{-}m//gc",
    {}
  ),

  -- Load the current file as nvim script
  -- vim.api.nvim_create_user_command(
  --   "TSource", -- this source
  --   "source %",
  --   {}
  -- )

  -- We will not add :Conf and :Config for now since Lazyim covers that

  --╭─────────────────────────────────────────────────────────────────────────────╮
  --│ Editing                                                                     │
  --╰─────────────────────────────────────────────────────────────────────────────╯

  -- ── Sorting ────────────────────────────────────────────────
  -- Add small ß to the start of selected line(s)
  vim.api.nvim_create_user_command("SortMark", "s/^/ß", {}),
  -- Repalce \n with capital ẞ anywhere except in front of small ß
  vim.api.nvim_create_user_command("SortCollapse", "'<,'>s/\\nß\\@!/ẞ/g", { range = true }),
  -- Sort regularly
  vim.api.nvim_create_user_command("SortSort", "'<,'>sort", { range = true }),
  -- Replace all captial ẞ with \n
  vim.api.nvim_create_user_command("SortExpand", "'<,'>s/ẞ/\\r/g", { range = true }),
  -- Remove small ß at the start of a line
  vim.api.nvim_create_user_command("SortTrim", "'<,'>s/^ß//", { range = true }),

  -- Read lines with raw hexadecimal encoding (xxd -r -p)
  vim.api.nvim_create_user_command("HexRead", "'<,'>!xxd -r -p|xxd", {}),

  -- Not great but suffices for now
  vim.api.nvim_create_user_command("Doc", [['<,'>s#^\(\s*\)//#\1 *]], { range = true }),

  -- TODO HexHex (binary -> hex) + HexBinary (hex -> binary)

  -- ╭───────────────────────────────────────────────────────────────────────────╮
  -- │ HACK: This vim.cmd must be last or the file errors. Can't be right.       │
  -- ╰───────────────────────────────────────────────────────────────────────────╯

  vim.cmd([[
  function! JumpToString(...)
    " Search for a:1 using jump command a:2 (n or N or empty)
    let l:jumpPattern = get(a:, 1)
    let l:jumpcmd = get(a:, 2, 'n')
    let l:oldPattern = getreg('/')
    let l:oldPatternType = getregtype('/')
    call setreg('/', l:jumpPattern, 'v')
     exec 'normal! '.l:jumpcmd
     normal! zt
    call setreg('/', l:oldPattern, l:oldPatternType)
  endfunction
]]),
}
