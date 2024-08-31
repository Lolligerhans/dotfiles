-- Commands and functions we want to keep out of keymaps.lua. But presumably we
-- will often use these things by creating a mapping there.

--TODO: Rename to "commands" or "functions"

function DIffToggle()
  if vim.opt.diff:get() then
    vim.cmd([[diffoff]])
  end
end

-- HACK: NOt sure if commands are supposed to be created this way in lazyvim
return
{

  vim.api.nvim_create_user_command(
  -- Command generating ctags
    "MakeTags",
    "!touch .ctagsignore && ctags -R --c++-kinds=+p --fields=+iaS --extras=+q",
    {}
  ),

  vim.api.nvim_create_user_command(
  -- Command generating ctags
    "MakeTagsAgain",
    "!rm tags && touch .ctagsignore && ctags -R --c++-kinds=+p --fields=+iaS --extras=+q",
    {}
  ),

  vim.api.nvim_create_user_command(
  -- Remove trailing whitespace
    "Rtw",
    "%s/\\s\\+$//c",
    {}
  ),

  vim.api.nvim_create_user_command(
  -- Remove ANSII (colour and other) escape codes
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

  -- Read lines with raw hexadecimal encoding (xxd -r -p)
  vim.api.nvim_create_user_command(
    "HexRead",
    "'<,'>!xxd -r -p|xxd",
    {}
  ),

  -- TODO HexHex (binary -> hex) + HexBinary (hex -> binary)

  -- ╭───────────────────────────────────────────────────────────────────────────╮
  -- │ HACK: This vim.cmd must be last or te file errors. Can't be right.        │
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
     normal! zz
    call setreg('/', l:oldPattern, l:oldPatternType)
  endfunction
]]),
}
