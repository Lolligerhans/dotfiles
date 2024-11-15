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

-- moved to <leader>ßL
m.del("n", "<leader>L")
-- TODO How to get the short log?
m.set("n", "<leader>ßL", "<cmd>Lazy<cr>", { remap = false, desc = "?Lazy log" })

-- changed to "<leader>L"
m.del("n", "<leader>l")
m.set("n", "<leader>L", "<cmd>Lazy<cr>", { remap = false, desc = "LazyVim" })

-- moved to <leader>ß:
m.del("n", "<leader>:")
m.set("n", "<leader>ß:", "<cmd>Telescope command_history<cr>",
  { remap = false, desc = "Command History" })

-- Replaced with our own (remains at <leader>ff)
m.del("n", "<leader><leader>")

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Global/Generic                                                            │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- FIXME: None of these mappings work with flash.nvim
-- FIXME: Using only the single-letter mappings does not enable using
--        double-bracket movements in operator-pending mode.
-- FIXME: None of these work in "replace-pending" mode

-- Try mapping öäÖÄ to produce []{} always, except for i_CTRL-V
m.set({ "", "!", "l" }, "<c-c>", "<esc>", { desc = "[Esc]" })
m.set({ "", "!", "l", "t", "o" }, "ö", "[", { remap = true })
m.set({ "", "!", "l", "t", "o" }, "Ö", "{", { remap = true })
m.set({ "", "!", "l", "t", "o" }, "öö", "[[", { remap = true })
m.set({ "", "!", "l", "t", "o" }, "ÖÖ", "]]", { remap = true })
m.set({ "", "!", "l", "t", "o" }, "ä", "]", { remap = true })
m.set({ "", "!", "l", "t", "o" }, "Ä", "}", { remap = true })
m.set({ "i" }, "ÖÖ", "{{", { remap = true }) -- for imap {{
m.set({ "i" }, "ÄÄ", "}}", { remap = true }) -- for imap }}
-- Quitting
m.set("n", "<c-q>", ":q<cr>", { desc = "Close window hard" })
m.set("n", "<leader>Q", ":sus<cr>", { remap = false, desc = "suspend" })
m.set("n", "<leader>qQ", ":qa<cr>", { remap = false, desc = "Quit hard" })

-- nnoremap <leader>: :enew\|pu=execute(':help')<c-f>T:ve
m.set("n", "<leader>:", ":enew|pu=execute(':help')<c-f>T:ve",
  { remap = false, desc = "Capture :command output" })

m.set("n", "<leader>qw", "<cmd>xa<cr>", { remap = false, desc = "Write & Quit" })

-- TODO Here we could add action mapping for F-keys
-- TODO F1: build, f2: run
-- TDOo <c-F12> reload vimrc/config?

m.set("i", "<F1>", "<nop>", { remap = false }) -- Remove nvim default mapping
m.set("n", "<F1>", "<cmd>make<cr>", { remap = false })
m.set("n", "<F2>", "<cmd>split term://./run.sh<cr>", { remap = false })

-- Delete errors for Shellcheck error code under cursor
m.set("n", "<leader>ces", "m`*<cmd>g//-2,+2d<cr>``", { remap = false, desc = "Code edit [s]hellcheck" })

-- Git add using bash alias 'a' in the LazyVim terminal popup
m.set("n", "<F5>", "<c-/>a<cr>", { remap = true, desc = "Git add" })
m.set("t", "<esc><esc>", "<c-/><c-n>", { remap = false })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Windows, tabs and viewiing                                                │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- ── Jumping and tags ───────────────────────────────────────
m.set("n", "<A-+>", "<C-w>v*", { remap = false, desc = "Search word in split window" })
m.set("n", "<A-9>", "<cmd>tab split<cr><C-]>zz", { remap = false, desc = "Jump to ta in new tab" })

-- ── Tabs ───────────────────────────────────────────────────
-- Switch tabs using AltGr-h AltGr-l. The main benefit is that we can cycle n tabs
-- with ~1*n key presses (rather than ~2*n when alternating gt or gT).
m.set("n", "ħ", "gT", { remap = false, desc = "tabprevious" })
m.set("n", "ł", "gt", { remap = false, desc = "tabnext" })
-- Split in new tab. Since the buffer is already open there is no reason to
-- start a new buffer.
m.set("n", "<c-w><c-t>", "<cmd>tab split<cr>", { remap = false, desc = "new tab" })

-- LazyVim defaults increases only 2 only
m.del("n", "<c-left>")
m.del("n", "<c-right>")
m.del("n", "<c-up>")
m.del("n", "<c-down>")
m.set("n", "<c-left>", "<cmd>vertical resize -10<cr>", { remap = false, desc = "Decrease window width" })
m.set("n", "<c-right>", "<cmd>vertical resize +10<cr>", { remap = false, desc = "Increase window width" })
m.set("n", "<c-down>", "<cmd>resize -10<cr>", { remap = false, desc = "Decrease window height" })
m.set("n", "<c-up>", "<cmd>resize +10<cr>", { remap = false, desc = "Increase window height" })

m.set("n", "<c-e>", "5<c-e>", { remap = false, desc = "Scroll view up" })
m.set("n", "<c-y>", "5<c-y>", { remap = false, desc = "Scroll view down" })

-- TODO: Bring back normal tabs in lazyvim
m.set("n", "<A-e>", "<cmd>BufferLineMovePrev<cr>", { remap = false, desc = "Move buffer left" })
m.set("n", "<A-y>", "<cmd>BufferLineMoveNext<cr>", { remap = false, desc = "Move buffer right" })

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
  "<cmd>-tab terminal<cr>",
  { remap = false, desc = "Terminal" })

-- TODO: How to define whichkey group?
m.set(
  "n", "<leader>tc",
  function() vim.opt.cursorcolumn = not vim.opt.cursorcolumn:get() end,
  { remap = false, desc = "Toggle cusor [c]olumn" }
)

m.set("n", "<A-h>", "zc", { remap = true, desc = "Close fold" })
m.set("n", "<A-l>", "zo", { remap = true, desc = "Open fold" })
m.set("n", "<A-H>", "zC", { remap = true, desc = "Close all folds" })
m.set("n", "<A-L>", "zO", { remap = true, desc = "Open all folds" })
m.set("n", "<A-j>", "zj", { remap = true, desc = "Jump to nect fold" })
m.set("n", "<A-k>", "zk", { remap = true, desc = "Jump to previous fold" })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Editing / Insert mode                                                     │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- ── Sorting ────────────────────────────────────────────────
-- TODO: How to do visual mode commands in lua?
m.set(
  "v", "<leader>is", "cẞstart<cr>ẞend<esc>P<esc>",
  { remap = false, desc = "(1) Sort range" }
)
m.set(
  "n", "<leader>isp", function() require("sort").mark_paragraph() end,
  { remap = false, desc = "(2-1) Mark as sorting paragraph" }
)
m.set(
  "n", "<leader>iss", function() require("sort").mark_sort() end,
  { remap = false, desc = "(2-2) Mark as sorting location" }
)
m.set(
  "n", "<leader>isS", function() require("sort").sort() end,
  { remap = false, desc = "(3) Process markers" }
)

m.set("n", "<leader>d<space>", "gElcw<space><esc>",
  { remap = false, desc = "Shrink leading whitespace" })

m.set("i", "{{", "{<cr>}<esc>O", { remap = false, desc = "Open block line" })
m.set("i", "{;", "{<cr>};<esc>O", { remap = false, desc = "Open block line with ;" })
m.set("i", "}}", "{<cr>}<left>", { remap = false, desc = "Open empty block line" })
m.set("i", "};", "{<cr>};<left><left>", { remap = false, desc = "Open empty block line with ;" })
m.set("i", "{}", "{}<left>", { remap = false, desc = "Open empty block" })

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

-- Convert binary <--> hexadecimal <--> hexdump
m.set({ "v" }, "<leader>xr", "<esc>'<kmh'>jml<cmd>HexRead<cr>'hjV'lk>",
  { remap = false, desc = "Hex read (hex->dump)" })
m.set({ "n" }, "<leader>cxr",
  "/[^[:xdigit:][:space:]]<cr>VN$/[[:xdigit:]]<cr>o^N<bslash>xr<cmd>silent nohl<cr>",
  { remap = false, desc = "Hex read (within next non-pure-hex lines)" })
m.set({ "v" }, "<leader>xx", "<cmd>!xxd -p<cr>", { remap = false, desc = "Hex encode (bin->hex)" })
m.set({ "v" }, "<leader>xb", "<cmd>!xxd -r -p<cr>", { remap = false, desc = "Hex decode (hex->bin)" })
m.set({ "v" }, "<leader>xs", "<cmd>!xxd -r | xxd -p<cr>", { remap = false, desc = "Hex string (dump->hex)" })

-- Replace { at end of line with { at start of line
-- FIXME: Does not work with our global "ö" → "{" mapping
m.set({ "n", "v" }, "<leader>{", ":s/\\(\\s*\\)\\S.\\{-}\\zs\\s*{$/\\r\\1{/g<cr>",
  { remap = false, desc = "Replace trailing {" }
)

-- Hard wrap after 80 characters. Because n_gww does not work on lines without
-- whitespace.
m.set({ "n", "v" }, "gwW", "<cmd>s/.\\{80}\\zs/\\r/g<cr>",
  { remap = false, desc = "hard wrap 80 characters" })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Movements                                                                 │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- NOTE LazyVim shows buffers in tablist. Once we get to change it, use
--     <c-{H, L}> to move between tabs, HL with their normal function.
-- m.set("n", "<c-h>", "<cmd>bN<cr>", { remap = false, desc = "Tab before" })
-- m.set("n", "<c-l>", "<cmd>bn<cr>", { remap = false, desc = "Tab next" })

-- Traverse changelist with <A-i> and <A-o>. Similar to the jumplist.
m.set("n", "<A-O>", "g;", { remap = false, desc = "Previous change" })
m.set("n", "<A-I>", "g,", { remap = false, desc = "Next change" })

m.set("n", "<F3>", "<cmd>cN<cr>zvzz", { remap = false, desc = "quickfix previous" })
m.set("n", "<F4>", "<cmd>cn<cr>zvzz", { remap = false, desc = "quickfix next" })
m.set("n", "<S-F3>", "<cmd>:cNf<cr>", { remap = false, desc = "quickfix file previous" })
m.set("n", "<S-F4>", "<cmd>:cnf<cr>", { remap = false, desc = "quickfix file next" })

-- Diff jumps
m.set("n", "<F9>", "[czz", { remap = false, desc = "hunk previous" })
m.set("n", "<F10>", "]czz", { remap = false, desc = "hunk next" })
m.set("n", "<S-F9>", "<F21>", { remap = true, desc = "conflict previous" })
m.set("n", "<S-F10>", "<F22>", { remap = true, desc = "conflict next" })
m.set("n", "<F21>", "<cmd>call JumpToString('^<<<<'..'<<<', 'N')<cr>",
  { remap = false, desc = "conflict previous" })
m.set("n", "<F22>", "<cmd>call JumpToString('^<<<<'..'<<<', 'n')<cr>",
  { remap = false, desc = "conflict next" })

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

-- This allows marking with m and jumping with M. Recover normal behaviour of
-- "M" in the new mappign "gM".
m.set("n", "M", "'", { remap = false, desc = "jump to mark" })
m.set("n", "gM", "M", { remap = false, desc = "To Middle line of window" })

-- ╭───────────────────────────────────────────────────────────╮
-- │ Mergetool mode                                            │
-- ╰───────────────────────────────────────────────────────────╯

--- NOTE: We try doing this in scripts.lua
-- vim.cmd([[
-- function DiffToggle()
--   if &diff
--     diffoff
--   else
--     diffthis
--   endif
-- endfunction
-- ]])
m.set("n", "dO", function() DiffToggle() end, { remap = false, desc = "Diff toggle" })

-- if vim.opt.diff:get() then
--   -- Wont trigger if we manually set diff mode, but ok for now.
--   m.set("n", "<F3>", "[czz", { remap = false, desc = "hunk previous" })
--   m.set("n", "<F4>", "]czz", { remap = false, desc = "hunk next" })
-- end

--╭────────────────────────────────────────────────────────────────────────────╮
--│ Plugin control                                                             │
--╰────────────────────────────────────────────────────────────────────────────╯

-- ── FzfLua ─────────────────────────────────────────────────
-- ß (fzf) Find file/buffer (<c-x>, <c-v>, <c-t> to split, vert, tab open them)
m.set({ "n" }, "ßf", "<cmd>FzfLua files<cr>", { remap = false, desc = "Find file" })
-- Similar to <leader>,
m.set({ "n" }, "ßb", "<cmd>FzfLua buffers<cr>", { remap = false, desc = "Find buffer" })
m.set({ "n" }, "ßt", "<cmd>FzfLua btags<cr>", { remap = false, desc = "Search buffer tags" })
m.set({ "n" }, "ßT", "<cmd>FzfLua tags<cr>", { remap = false, desc = "Search tags (.tags)" })
m.set({ "n" }, "ßl", "<cmd>FzfLua lines<cr>", { remap = false, desc = "Search loaded buffers" })
m.set({ "n" }, "ßß", "<cmd>FzfLua blines<cr>", { remap = false, desc = "Search buffer" })
m.set({ "n" }, "ßg", "<cmd>FzfLua grep<cr>", { remap = false, desc = "Search (ripgrep)" })
m.set({ "n" }, "ßG", "<cmd>FzfLua grep_project<cr>", { remap = false, desc = "Search project ripgrep (?)" })
m.set({ "n" }, "ßL", "<cmd>FzfLua live_grep_glob<cr>", { remap = false, desc = "Search live (ripgrep)" })
m.set({ "n" }, "ßc", "<cmd>FzfLua live_grep_resume<cr>", { remap = false, desc = "Continue FzfLua search" })
m.set({ "n" }, "ßn", "<cmd>FzfLua live_grep_native<cr>", { remap = false, desc = "Search (native grep) (faster?)" })
m.set({ "n" }, "ßs", "<cmd>FzfLua tags_grep_cword<cr>", { remap = false, desc = "Search cursor tag" })
m.set({ "n" }, "ßw", "<cmd>FzfLua grep_cword<cr>", { remap = false, desc = "Search cursor word" })
m.set({ "v" }, "<leader>ü", "<cmd>FzfLua grep_visual<cr>", { remap = false, desc = "Search visual selection" }) -- visual-ß is for surround already
m.set({ "n" }, "ßr", "<cmd>FzfLua lsp_references<cr>", { remap = false, desc = "Search references" })
m.set({ "n" }, "ßü", "<cmd>FzfLua lsp_document_symbols<cr>", { remap = false, desc = "Search document symbols" })
m.set({ "n" }, "ßÜ", "<cmd>FzfLua lsp_workspace_symbols<cr>", { remap = false, desc = "Search workspace symbols" })
m.set({ "n" }, "ßq", "<cmd>FzfLua quickfix<cr>", { remap = false, desc = "Search quickfix window" })
-- Remaps to more conventient key combinations:
m.set({ "n" }, "<leader><leader>", "ßf", { remap = true, desc = "Find file" })
m.set({ "n" }, "<leader><C-space>", "ßL", { remap = true, desc = "Search lines (ripgrep)" })
m.set({ "n" }, "ü", "ßt", { remap = true, desc = "Search tags (buffer)" })
m.set({ "n" }, "Ü", "ßT", { remap = true, desc = "Search tags (.tags)" })
m.set({ "n" }, "<leader>ü", "ßü", { remap = true, desc = "Search document symbols" })
m.set({ "n" }, "<leader>Ü", "ßÜ", { remap = true, desc = "Search workspace symbols" })

-- TODO Name the <leader>i group "insert/edit text"
m.set({ "n", "v" }, "<leader>ib", "<cmd>:CBclbox<cr>", { remap = false, desc = "Insert box header" })
m.set({ "n", "v" }, "<leader>il", "<cmd>:CBclline<cr>", { remap = false, desc = "Insert line header" })

-- Noice
m.set({ "n" }, "<leader>uH", "<cmd>NoiceHistory<cr>G", { remap = false, desc = "History" })

-- Tagbar <C-F10>
m.set("n", "<F34>", "<cmd>TagbarToggle<cr>", { remap = false, desc = "Tagbar" })

-- Noice/Messages
m.set("n", "<leader>mh", "<cmd>NoiceHistory<cr>G", { remap = false, desc = "Message history" })
m.set("n", "<leader>ml", "<cmd>Noice last<cr>", { remap = false, desc = "Last message" })

-- ArgWrap
m.set("n", "gS", ":ArgWrap<CR>", { remap = false, desc = "(Un)wrap args" })

-- ╭───────────────────────────────────────────────────────────────────────────╮
-- │ Digraphs / Symbols                                                        │
-- ╰───────────────────────────────────────────────────────────────────────────╯

-- i-CTRL-k is overwritten by LazyVIm, so onlynoremap to it

---@param code string number in decimal
---@param digraph string two digraph letters
---@param _description string unused
--- Set a digraph and the corresponding <c-ß> keymap
local asDigraph = function(digraph, code, _description)
  vim.cmd("digraph " .. digraph .. " " .. code)
end

-- Recover digraph overwritten by LazyVim
m.set("i", "<c-l>", "<c-k>", { remap = false, desc = "digraph" })

---Map any text in input mode after double <C-l>
local inputMap = function(input, output)
  m.set({ "i" }, "<C-l><C-l>" .. input, output,
    { remap = false })
end

-- Symbol representing vertical (non-breaking) space. Use <sp><sp> or NS for the
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

-- Large, square and curly brackets (with top, middle, bottom).
-- You can copy-paste from here, too.
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
