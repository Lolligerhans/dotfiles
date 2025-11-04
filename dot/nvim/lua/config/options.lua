-- Here we configure the vim 'set xyz' options.

local o = vim.opt

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ LazyVim                                                                   │
-- ╰───────────────────────────────────────────────────────────────────────────╯

vim.g.autoformat = true
vim.g.snacks_animate = false

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Look/Display                                                              │
-- ╰───────────────────────────────────────────────────────────────────────────╯

o.scrolloff = 9 -- At most 9 lineas above/below the cursor when scrolling

o.cursorline = true
o.cursorlineopt = "both"
o.cursorcolumn = true
o.laststatus = 3
o.number = true
o.relativenumber = true

o.showbreak = "↪"
o.wrap = true -- wrap long lines
o.breakindent = true -- indent wrapped lines
o.breakindentopt = "min:20,shift:8,list:-1" -- default ""
o.linebreak = true -- dont wrap within words
o.smoothscroll = true -- scrolling by screen line

o.colorcolumn = { 81 }

o.list = true
o.listchars = {
  -- extends = '…',
  -- precedes = '…',
  conceal = "┊",
  -- eol = '↲',
  nbsp = "␣",
  tab = "▸·",
  trail = "▓",
}

-- vimrc fillchars options
-- set fillchars=vert:▏,foldopen:▾,foldclose:▸,fold:─,foldsep:│
o.fillchars.diff = "░" -- FIXME: Has no effect

-- LazyVim has its own folding. Else use o.foldcolumn = "auto".
o.foldcolumn = "0"

-- TODO terminal colors?

-- FIXME Cursor highlight should be inverse but is not
o.guicursor = "n-v-c:block,"
  .. "i-ci-ve-o:block,"
  .. "r-cr:hor20,"
  .. "a:blinkwait700-blinkoff400-blinkon250-inverse/reverse,"
  .. "sm:block-blinkwait175-blinkoff150-blinkon175"

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Behaviour                                                                 │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- TODO: filetype plugin indent detection on
--       treat .sh as bash, .test .inc as c++
o.path:append({ "**" })
o.wildignore:append({ "tags", ".git" })
o.wildignorecase = true
o.fileignorecase = true
o.makeprg = "./run.sh build"

-- vim.opt.foldmethid = "indent" -- not sure we want this
o.foldenable = true
o.foldlevelstart = 99

o.splitright = true
o.splitbelow = true

o.showcmd = true
o.showmatch = true -- TODO: was off in vimrc but we might like it?
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true
o.mouse = "a"
o.fileformat = "unix"

o.timeoutlen = 1000 -- For regular mappings
o.ttimeoutlen = 50 -- Only for <esc> byte \x1b

-- TODO No idea how this would be done in lua here
vim.cmd([[
set complete-=t
]])

o.secure = false
o.exrc = true

-- We could have session commands here? Lazyvim saves sessions be default, but
-- we could still make a long term session.

-- TODO BASH_ENV needed? I do not think so

o.modeline = true

o.wildmenu = true

o.undofile = true

o.virtualedit = { "block", "insert" }

-- set nohidden? We had it in .vimrc, but doesnt seem needed here so far
-- TODO wrong?
o.belloff = ""
o.langremap = false

-- How far to scroll vertically when needed. Maybe sync with tabstop?
o.sidescroll = 2

o.shortmess = "finxltToO"

o.sessionoptions = {
  "blank",
  "buffers",
  "curdir",
  "folds",
  "help",
  "options",
  "tabpages",
  "winsize",
  "terminal",
}

o.startofline = false

-- No -uu option when using ripgrep
o.grepprg = "rg --vimgrep" -- LazyVim default anyway

o.allowrevins = true

vim.g.netrw_liststyle = 3

-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │ editing                                                                  │
-- ╰──────────────────────────────────────────────────────────────────────────╯

o.digraph = false
o.tabstop = 8
o.expandtab = true
o.softtabstop = 2 -- Pseudo-tab width. Keep tabstop at 8.
o.shiftwidth = 2 -- Else uses tabstop
o.smartindent = false -- lazyvim: true
o.cindent = true -- lazyvimn : false
o.smarttab = true
o.textwidth = 80 -- lazyvim: 0
-- FIXME: there appears an "o" in ':se fo?' too? something rests this
o.formatoptions = "cr/qn1jl" -- :h fo-table
-- The lua string eats one level of backslash \ escaping.
-- Generic is either of these two doc-block-like formats:
--    @word
--    @word word:
-- Specific uses actual doc-block keywords (with optional type):
--    @return {type}
--    @param {type} word
local generic = [[\w\+\%(\s\+\w\+:\)\?\s]]
local type = [[\%({.*}\s\)\?]] -- Anything within {}
local arg0 = [[\%(return\|type\)\s\+]]
local arg1 = [[\%(param\|typedef\|property\|callback\)\s\+]]
local target = [=[\s*[^[:space:]]\+\s]=] -- WORD
local specific = [[\%(]] .. arg0 .. type .. [[\|]] .. arg1 .. type .. target .. [[\)]]
local docblock = [[@\%(]] .. specific .. [[\|]] .. generic .. [[\)]]
-- local todo = [[\%(TEST\|TODO\|NOTE\|FIXME\|HACK\|INFO\):\?]]
-- Listing words not flexible enough. Detect by all caps word instead
local todo = [[\%(\<\u\u\+\>\):\?]]
o.formatlistpat = [[^\s*\(•\|◦\|·\|]]
  .. docblock
  .. [[\|-\s\%(\s*\w*:\)\?\|]]
  .. todo
  .. [[\|\d\+[\]:.)}\t ]\)\s*]]
o.joinspaces = false

-- TODO: Filetype mappings for our comment-preserving comment-out mappings.

-- ╭───────────────────────────────────────────────────────────╮
-- │ Mergetool mode                                            │
-- ╰───────────────────────────────────────────────────────────╯

if vim.opt.diff:get() then
  -- o.diffopt = "iwhite"
  o.tabline = ""
end
