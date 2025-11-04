-- Wrap and unwrap arguments. Useful for temporarily formatting function
-- parameters as lines, enabling simpler editing: sorting, visual-block mode,
-- etc.

-- Previously "https://github.com/FooSoft/vim-argwrap"

-- Default settings:
--        require('argonaut').setup({
--            brace_last_indent = false,
--            brace_last_wrap = true,
--            brace_pad = false,
--            comma_last = false,
--            comma_prefix = false,
--            comma_prefix_indent = false,
--            limit_cols = 512,
--            limit_rows = 64,
--            by_filetype = {
--                go = {comma_last = true},
--            },
--        })

return {
  {
    "https://git.sr.ht/~foosoft/argonaut.nvim",
    keys = {
      {
        "gS",
        "<cmd>ArgonautToggle<cr>",
        mode = "n",
        remap = false,
        desc = "Wrap/unwrap args",
      },
      -- vim.keymap.set('n', '<leader>a', ':<c-u>ArgonautToggle<cr>', {noremap = true, silent = true})
      -- vim.keymap.set({'x', 'o'}, 'ia', ':<c-u>ArgonautObject inner<cr>', {noremap = true, silent = true})
      -- vim.keymap.set({'x', 'o'}, 'aa', ':<c-u>ArgonautObject outer<cr>', {noremap = true, silent = true})
      -- vim.keymap.set({'x', 'o', 'n'}, '<leader>n', ':<c-u>ArgonautObject inner<cr>', {noremap = true, silent = true})
      -- vim.keymap.set({'x', 'o', 'n'}, '<leader>p', ':<c-u>ArgonautObject outer<cr>', {noremap = true, silent = true})
    },
  },
}
