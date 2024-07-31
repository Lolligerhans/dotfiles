-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local m = vim.keymap

--map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Replacements / Changes                                                    │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- INFO: We preserve replaced commands below prefix "<leader>ß"
-- TODO: Name this group something fitting

-- LazyVim defaults that we move slightly deeper
-- changed to "<leader>L"
m.del("n", "<leader>l")
-- moved to <leader>ß
m.del("n", "<leader>L")
m.set("n", "<leader>L", "<cmd>Lazy<cr>", { remap = false, desc = "LazyVim" })
-- TODO How to get the short log?
m.set("n", "<leader>ßL", "<cmd>Lazy<cr>", { remap = false, desc = "?Lazy log" })
-- moved to <leader>ß:
m.del("n", "<leader>:")
m.set("n", "<leader>:", "<cmd>Telescope command_history<cr>",
  { remap = false, desc = "Command History" })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Global/Generic                                                            │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- Using []{} through öä
-- FIXME Does not work with flash.nvim
-- FIXME Does not work in replace-pending
m.set({ "", "!", "l" }, "<c-c>", "<esc>", { desc = "[Esc]" })
m.set({ "", "!", "l", "t" }, "ö", "[", { remap = true }) -- Essentially replace the key as far as vim is concerned
m.set({ "", "!", "l", "t" }, "Ö", "{", { remap = true })
m.set({ "", "!", "l", "t" }, "ä", "]", { remap = true })
m.set({ "", "!", "l", "t", "o" }, "Ä", "}", { remap = true })
-- Quitting
m.set("n", "<c-q>", ":q<cr>", { desc = "Close window hard" })
m.set("n", "<leader>Q", ":sus<cr>", { remap = false, desc = "suspend" })
m.set("n", "<leader>qQ", ":qa<cr>", { remap = false, desc = "Quit hard" })

-- nnoremap <leader>: :enew\|pu=execute(':help')<c-f>T:ve
m.set("n", "<leader>:", ":enew\\|pu=execute(':help')<c-f>T:ve",
  { remap = false, desc = "Capture :cm output" })

m.set("n", "<leader>qw", "<cmd>xa<cr>", { remap = false, desc = "Write & Quit" })

-- TODO Here we could add action mapping for F-keys
-- TODO F1: build, f2: run
-- TDOo <c-F12> reload vimrc/config?

-- Remove annoying default <f1> mapping
m.set("i", "<f1>", "<nop>", { remap = false })
m.set("n", "<f1>", "<cmd>make<cr>", { remap = false })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Windows, tabs and viewiing                                                │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- TODO Bring back normal tabs in lazyvim

m.set({ "n" }, "<A-.>", "<cmd>30vsp .<cr>", { remap = false, desc = "Folder of this file" })

-- nnoremap <C-l> gt
-- nnoremap <C-Right> gt
-- nnoremap <C-h> gT
-- nnoremap <C-Left> gT
-- nnoremap <A-h> <C-w>h
-- nnoremap <A-j> <C-w>j
-- nnoremap <A-k> <C-w>k
-- nnoremap <A-l> <C-w>l

m.set("c", "<S-F9>", "windo diffoff<cr>", { remap = false, desc = "undiff window(s)" })
m.set("c", "<S-F10>", "windo diffthis<cr>", { remap = false, desc = "diff window(s)" })
-- TODO tagber?
-- TODO Indent guides?


-- " switch between {source, header, include, test} file
m.set("n", "<leader>bmh", "<cmd>fin %:t:r.h<cr>", { remap = false, desc = ".h" })
m.set("n", "<leader>bms", "<cmd>fin %:t:r.cpp<cr>", { remap = false, desc = ".cpp" })
m.set("n", "<leader>bmi", "<cmd>fin %:t:r.inc<cr>", { remap = false, desc = ".inc" })
m.set("n", "<leader>bmt", "<cmd>fin %:t:r.test<cr>", { remap = false, desc = ".test" })

-- TODO we remove gogarb for now. Doesnt fir into the lack of tabs anyway. same
--      for <leader>B for going to lasttab and <leader>G starting Fugitive in
--      garb tab.

-- For now we will be using the default terminal mode maps for mocing etc.
m.set("n", "<leader>wt",
  "<cmd>-tab terminal<cr>i",
  { remap = false, desc = "Terminal" })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Editing / Insert mode                                                     │
-- ╰───────────────────────────────────────────────────────────────────────────╯

vim.cmd([[
" Delete whitespace between WORDS
nnoremap <leader>d<space> BElcw<space><esc>
" Delete whitespace padding within () TODO
"nnoremap <leader>d( <esc>
]])
-- FIXME Not working with auto-{} creation
m.set("i", "{{", "{<cr>}<esc>O", { remap = false, desc = "Block start" })

m.set("i", "<c-r>L", 'line(".")', { remap = false, expr = true, desc = "Lineno" })

-- TODO Filetype specific
-- nnoremap <leader>b m`GooCBench: *``

m.set("t", "<c-r>", "'<c-\\><c-n>\"'.nr2char(getchar()).'pi'",
  { remap = false, expr = true, desc = "Register..." })

-- Scrape function calls from the end.Anti-join. Does not re-align, so
-- autoformatter must salvage the remains.
-- Inserts \r at ,<space> {<space> <space>} and similar.
-- TODO: We iverwrite vim's gj. Do we care? we can always unmap gj ad-hoc.
m.set({ "n", "v" }, "gj",
  "<cmd>s/.*\\(,\\zs \\+\\ze\\|\\zs \\+\\ze[\\])}]\\|[\\[({]\\zs \\+\\ze\\)/\\r<cr>``",
  { remap = false, desc = "Scrape at end" })

-- Create hexdump encoding
m.set({ "v" }, "<leader>xr", "<esc>'<kmh'>jml<cmd>HexRead<cr>'hjV'lk>",
  { remap = false, desc = "Hex read" })
m.set({ "n" }, "<leader>cxr",
  "/[^[:xdigit:][:space:]]<cr>VN$/[[:xdigit:]]<cr>o^N<bslash>xr<cmd>silent nohl<cr>",
  { remap = false, desc = "Hex read" })

-- Replace { at end of line with { at start of line
-- TODO: Does this work with our global ö → { mapping}
m.set("v", "<leader>{", ":s/\\(\\s*\\)\\S.\\{-}\\zs\\s*{$/\\r\\1{/g<cr>",
  { remap = false, desc = "Replace trailing {" }
)

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Movements                                                                 │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- NOTE LazyVim shows buffers in tablist. Once we get to change it, use
--     <c-{H, L}> to move between tabs, HL with their normal function.
m.set("n", "<c-h>", "<cmd>bN<cr>", { remap = false, desc = "Tab before" })
m.set("n", "<c-l>", "<cmd>bn<cr>", { remap = false, desc = "Tab next" })

-- temporary. do we like this?
-- FIXME lazyvim jumplist is broken
m.set("n", "<A-h>", "g;", { remap = false, desc = "Change backwards" })
m.set("n", "<A-h>", "g,", { remap = false, desc = "Change forwards" })

m.set("n", "<F3>", "<cmd>cN<cr>zvzz", { remap = false, desc = "quickfix previous" })
m.set("n", "<F4>", "<cmd>cn<cr>zvzz", { remap = false, desc = "quickfix next" })
m.set("n", "<S-F3>", "<cmd>:cNf<cr>", { remap = false, desc = "quickfix file previous" })
m.set("n", "<S-F4>", "<cmd>:cnf<cr>", { remap = false, desc = "quickfix file next" })
-- TODO map some keys to ':n'?

-- Diff jumps
m.set("n", "<F9>", "[czz", { remap = false, desc = "hunk previous" })
m.set("n", "<F10>", "]czz", { remap = false, desc = "hunk next" })
m.set("n", "<F9>", "[czz", { remap = false, desc = "hunk previous" })
m.set("n", "<F10>", "]czz", { remap = false, desc = "hunk next" })
m.set("n", "<S-F9>", "<cmd>call JumpToString('<<<<<<<', 'N')<cr>",
  { remap = false, desc = "conflict previous" })
m.set("n", "<S-F10>", "<cmd>call JumpToString('>>>>>>>', 'n')<cr>",
  { remap = false, desc = "conflict next" })

if vim.opt.diff:get() then
  -- This is for vimdiff. Wont trigger if we manually set, but ok for now.
  m.set("n", "<F3>", "[czz", { remap = false, desc = "hunk previous" })
  m.set("n", "<F4>", "]czz", { remap = false, desc = "hunk next" })
end

-- LazyVim setting something similar enough
-- We could think about mapping Alt-j to the regular behaviour
--   nnoremap k gk
--   nnoremap j gj
--   nnoremap <Up> gk
--   inoremap <Up> <C-O>gk
--   nnoremap <Down> gj
--   inoremap <Down> <C-O>gj

-- Retired
-- nnoremap ⅞ yiw<c-w>vh/\<<c-r>0\><cr> " shift altgr 7

--╭────────────────────────────────────────────────────────────────────────────╮
--│ Plugin control                                                             │
--╰────────────────────────────────────────────────────────────────────────────╯

-- ß (fzf) Find file/buffer (<c-x>, <c-v>, <c-t> to split, vert, tab open them)
m.set({ "n" }, "ßf", "<cmd>Files<cr>", { remap = false, desc = "Files" })
m.set({ "n" }, "ßb", "<cmd>Buffers<cr>", { remap = false, desc = "Buffer list" }) -- <leader>,
m.set({ "n" }, "ßt", "<cmd>Tags<cr>", { remap = false, desc = "tags (.tags)" })
m.set({ "n" }, "ßT", "<cmd>BTags<cr>", { remap = false, desc = "tags (buffer)" })
m.set({ "n" }, "ßl", "<cmd>Lines<cr>", { remap = false, desc = "Lines (loaded buffers)" })
m.set({ "n" }, "ßL", "<cmd>BLines<cr>", { remap = false, desc = "Lines (this buffer)" })
-- Use :Rg for static ripgrep query to be searched with fzf
m.set({ "n" }, "ßg", "<cmd>RG<cr>", { remap = false, desc = "Lines (ripgrep)" })

-- TODO Name the <leader>i group "insert/edit text"
m.set({ "n", "v" }, "<leader>ib", "<cmd>:CBclbox<cr>", { remap = false, desc = "Box insert" })

-- Noice
m.set({ "n" }, "<leader>uH", "<cmd>Noice history<cr>G", { remap = false, desc = "History <cmd>" })

-- Tagbar
m.set("n", "<F34>", "<cmd>TagbarToggle<cr>", { remap = false, desc = "Tagbar" })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Digraphs / Symbols                                                        │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- i-CTRL-k is overwritten by LazyVIm, so onlynoremap to it

---@param code string number in decimal
---@param digraph string two digraph letters
---@param description string description used for map()
--- Set a digraph and the corresponding <c-ß> keymap
local asDigraph = function(digraph, code, description)
  vim.cmd("digraph " .. digraph .. " " .. code)
  m.set({ "i" }, "<c-ß>" .. digraph, "<c-k>" .. digraph,
    { remap = false, desc = description })
end

---Map any text in input mode after double <c-ß>
local inputMap = function(input, output)
  m.set({ "i" }, "<c-ß><-ß>" .. input, output,
    { remap = false })
end

-- Space symbol for vertical space (not the space character). Use <sp><sp> for
-- non-breaking space character.
asDigraph("sp", "9251", "␣")
-- Heavy Round-Tipped Rightwards Arrow. Use AltGr-i ( → ) for normal arrow.
asDigraph("->", "10140", "➜")
-- Dot-shaped bullet(-point) in large, black, white
asDigraph("OO", "9679", "● Large")
asDigraph("oo", "8226", "• Black")
asDigraph("oO", "9702", "◦ White")
--.M
asDigraph(".H", "8259", "⁃ Hyphenation bullet")
asDigraph(".h", "8231", "‧ Hyphenation point")
-- Source codeable symbols
asDigraph("ky", "128713", "⚿ Key")
asDigraph("KY", "128447", "🗝 Old key")
asDigraph("II", "8505", "ℹ Information - fancy ornament i")
asDigraph("ii", "128712", "🛈  Information i circled")
asDigraph("en", "9881", "⚙ engine/gear/settings/running")
asDigraph("to", "128736", "🛠 Toools")
asDigraph("fo", "128448", "🗀 folder")
asDigraph("bo", "128366", "🕮  book")
asDigraph("ve", "127301", "🅅 Letter v in box ('version')")
-- xx/ok symbols in variants
asDigraph("xx", "10006", "✕ Multipliction x")
asDigraph("Xx", "10006", "✖ Heavy multipliction x")
asDigraph("ok", "10004", "✔ Heavy check mark")
-- Emoji variants
inputMap("xx", "✖️")
inputMap("ok", "✔️")
asDigraph("++", "10133", "➕ Heavy plus sign")
asDigraph("--", "10134", "➖ Heavy minus sign")
asDigraph("**", "10033", "✱ Heavy Asterisk")
asDigraph("xX", "10062", "❎")
asDigraph("oK", "9989", "✅")
-- emoji box empty
-- ☑️ emoji box with checkmark
-- Checkmark-box and empty checkmark-box
asDigraph("bb", "9744", "☐ (box empty)")
asDigraph("bv", "9745", "☑ (box with check mark)")
asDigraph("bx", "9746", "☒ (box with x)")
asDigraph("XX", "10060", "❌")
-- Underscores _ should not be useed (reserved) but we do anyway
asDigraph("__", "128711", "🛇")
asDigraph("_-", "128683", "🚫")
asDigraph("-_", "9940", "⛔  No entry sign")
-- Ornament exclamation and question marks to mark stuff in code
asDigraph("??", "10068", "? emoji")
asDigraph("!!", "10069", "! emoji")
asDigraph("?.", "10067", "? ornament")
asDigraph("!.", "10071", "! ornament")
asDigraph("wa", "9888", "⚠ (triangle attention sign)")
inputMap("warning", "⚠️")
-- git branch
asDigraph("gb", "9095", "⎇")
-- Round <num-pad-position> box-drawing corner
asDigraph("r7", "9581", "╭")
asDigraph("r9", "9582", "╮")
asDigraph("r3", "9583", "╯")
asDigraph("r1", "9584", "╰")

-- Other unicode/utf characters
-- Superscript letters
-- inoremap <leader>ua <c-v>u1d43
-- inoremap <leader>ub <c-v>u1d47
-- inoremap <leader>uc <c-v>u1d9c
-- inoremap <leader>ud <c-v>u1d48
-- inoremap <leader>ue <c-v>u1d49
-- inoremap <leader>uf <c-v>u1da0
-- inoremap <leader>ug <c-v>u1d4d
-- inoremap <leader>uh <c-v>u02b0
-- inoremap <leader>ui <c-v>u2071
-- inoremap <leader>uj <c-v>u02b2
-- inoremap <leader>uk <c-v>u1d4f
-- inoremap <leader>ul <c-v>u02e1
-- inoremap <leader>um <c-v>u1d50
-- inoremap <leader>un <c-v>u207f
-- inoremap <leader>uo <c-v>u1d52
-- inoremap <leader>up <c-v>u1d56
-- inoremap <leader>uq <c-v>U000107a5
-- inoremap <leader>ur <c-v>u02b3
-- inoremap <leader>us <c-v>u02e2
-- inoremap <leader>ut <c-v>u1d57
-- inoremap <leader>uu <c-v>u1d58
-- inoremap <leader>uv <c-v>u1d5b
-- inoremap <leader>uw <c-v>u02b7
-- inoremap <leader>ux <c-v>u02e3
-- inoremap <leader>uy <c-v>u02b8
-- inoremap <leader>uz <c-v>u1db

inputMap("wood", "🪵")
inputMap("brick", "🧱")
inputMap("sheep", "🐑")
inputMap("wheat", "🌾")
inputMap("ore", "🪨")
inputMap("map", "🗺")
inputMap("globe", "🌎")
inputMap("card", "🂠")
inputMap("compass", "🧭")
inputMap("loupe", "🔍")
inputMap("eye", "👁")
inputMap("die", "🎲")
inputMap("stopwatch", "⏱")
inputMap("plaster", "🩹")
inputMap("hospital", "🏥")
inputMap("syringe", "💉")
inputMap("coconut", "🥥")
-- Chess symbols ('c' for chess)
inputMap("cc", "🙾")
inputMap("cC", "🙿")
inputMap("cS", "■")
inputMap("cs", "□")
inputMap("ck", "♔")
inputMap("cq", "♕")
inputMap("cr", "♖")
inputMap("cb", "♗")
inputMap("cn", "♘")
inputMap("cp", "♙")
inputMap("cK", "♚")
inputMap("cQ", "♛")
inputMap("cR", "♜")
inputMap("cB", "♝")
inputMap("cN", "♞")
inputMap("cP", "♟")

-- Large, square and curly brackets (with top, middle, bottom)
inputMap("(t", "⎛")
inputMap("(m", "⎜")
inputMap("(b", "⎝")
inputMap(")t", "⎞")
inputMap(")m", "⎟")
inputMap(")b", "⎠")
inputMap("[t", "⎡")
inputMap("[m", "⎢")
inputMap("[b", "⎣")
inputMap("]t", "⎤")
inputMap("]m", "⎥")
inputMap("]b", "⎦")
inputMap("{t", "⎧")
inputMap("{m", "⎪")
inputMap("{M", "⎨")
inputMap("{b", "⎩")
inputMap("}t", "⎫")
inputMap("}m", "⎪")
inputMap("}M", "⎬")
inputMap("}b", "⎭")
