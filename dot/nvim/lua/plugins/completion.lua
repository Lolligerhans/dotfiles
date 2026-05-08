return {
  {
    "https://github.com/saghen/blink.cmp",
    keys = {
      {
        -- In the LazyVim setup, blink.cmp uses <CR> to accept completions. However, because completions triggers always
        -- and include snippets they tend to match too often. This results in problems entering a raw <CR> which will
        -- most of the time be interpreted as "accept completion" when a line ends in the middle of a word. While that
        -- is rare in C++, it is common Markdown.
        -- For example, the line
        --    # Plan
        -- attempts to trigger the snippet ***|*** for cursive-bold text.
        -- With this we can use <Space><CR> to produce an unmapped <CR>. We probably do not want to end in single space
        -- anyway, and completions by blink appear not to trigger after spaces.
        --
        -- Alternatively we could try mocing blink.cmp to <Tab> or use <C-E> to explicitly not-complete.
        "<Space><CR>",
        "<CR>",
        -- Not using mapmode-l because command mode <CR> need not be mapped.
        -- TODO: Do we want Lang-Args to be mapped? See mapmode-l.
        mode = { "i" },
        remap = false, -- !
        desc = "<CR> (noremap)",
      },
    },
  },
}
