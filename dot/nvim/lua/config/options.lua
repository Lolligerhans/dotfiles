-- Here we configure the vim 'set xyz' options.

local o = vim.opt

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Look/Display                                                              │
-- ╰───────────────────────────────────────────────────────────────────────────╯

o.cursorline = true
o.cursorcolumn = true
o.laststatus = 2
o.number = true
o.relativenumber = true;

o.wrap = true;         -- wrap long lines
o.linebreak = false;   -- dont wrap within words
o.smoothscroll = true; -- scrolling by screen line

o.colorcolumn = { 81 }

o.list = true
o.listchars =
{
  -- extends = '…',
  -- precedes = '…',
  conceal = '┊',
  -- eol = '↲',
  nbsp = '␣',
  tab = '▸·',
  trail = '▓',
}

o.foldcolumn = "auto"

-- TODO terminal colors?

-- FIXME Cursor highlight should be inverse but is not
o.guicursor =
"n-v-c:block,\z
i-ci-ve:block,\z
r-cr:block,\z
o:block,\z
a:blinkwait700-blinkoff400-blinkon250-inverse/reverse,\z
sm:block-blinkwait175-blinkoff150-blinkon175"

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Behaviour                                                                 │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- TODO: filetype plugin indent detection on
--       treat .sh as bash, .test .inc as c++
o.path:append { "**" }
o.wildignore:append { "tags", "Session.vim", "Session_active.vim", ".git" }
o.wildignorecase = true
o.fileignorecase = true
o.makeprg = "./run.sh make"

-- vim.opt.foldmethid = "indent" -- not sure we want this

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

o.ttimeoutlen = 50 -- Was ok on vim. Too short now?

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

o.sidescroll = 0 -- How far to scroll vertically when needed

o.shortmess = "finxltToO"

o.sessionoptions = {
  "blank", "buffers", "curdir", "folds", "help", "options", "tabpages", "winsize", "terminal"
}

o.startofline = false

o.grepprg = "rg --vimgrep" -- LazyVim default anyway
vim.g.netrw_liststyle = 3

o.foldlevelstart = 3

-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │ editing                                                                  │
-- ╰──────────────────────────────────────────────────────────────────────────╯

o.expandtab = true
o.tabstop = 8
o.softtabstop = 2            -- Pseudo-tab width. Keep tabstop at 8.
o.shiftwidth = 2             -- Else uses tabstop
o.smartindent = false        -- lazyvim: true
o.cindent = true             -- lazyvimn : false
o.smarttab = true
o.textwidth = 80             -- lazyvim: 0
-- FIXME: there appears an "o" in ':se fo?' too? something rests this
o.formatoptions = "cr/qn1jl" -- :h fo-table
-- The lua string eats one level of bakspace \ escapin
o.formatlistpat = "^\\s*\\(•\\|◦\\|·\\|TODO:\\?\\|NOTE\\|FIXME\\|\\d\\+[\\]:.)}\\t ]\\)\\s*"
o.joinspaces = false

-- TODO: filetype mappings for our comment-preserving ground mappings. Or can
--     you maybe even use a vim indternal variable as comment string? sad
