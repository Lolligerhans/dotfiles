-- Add custom text object to mini.ai. This is needed because mini.ai forgot to
-- include the capitalized 'B' operator! Not sure if previously I was
-- accidentally using another plugin for that? In any case we want the capital
-- 'B' to be any [] or {} block.

-- https://github.com/nvim-mini/mini.nvim/blob/f90b6b820062fc06d6d51ed61a0f9b7f9a13b01b/lua/mini/ai.lua#L1081-L1124
-- This is how mini.ai predefined 'b' operator is implemented. We adjust this by
-- removing only the () round braces part.
--        -- Brackets
--        ['b'] = { { '%b()', '%b[]', '%b{}' }, '^.().*().$' },

-- https://github.com/nvim-mini/mini.nvim/discussions/1519
-- require('mini.ai').setup({
--   custom_textobjects = {
--     ['c'] = { '%b()', '^.().*().$' },
--     ['C'] = { '%b()', '^.%s*().-()%s*.$' },
--     ['B'] = { { '%b()', '%b[]', '%b{}' }, '^.%s*().-()%s*.$' },
--   },
-- })

return {
  {
    -- NOTE: Was moved onGitHub to nvim-mini/mini.nvim, but LazyVim still uses
    --       this repo. Once LazyVim moves, update the URL.
    "https://github.com/nvim-mini/mini.ai",
    opts = {
      -- local gen_spec = require("mini.ai").gen_spec
      -- opts.custom_textobjects['B'] = gen_spec.argument({ brackets = { "%b[]", "%b{}" }, })
      custom_textobjects = {
        -- I assume the '()' token stand for the matched start and end of the
        -- allowed [] and {} regions, while the '.' regex around them will match
        -- those characters. In-between '.*' anything matches. Not sure if
        -- correct.
        ["B"] = { { "%b[]", "%b{}" }, "^.().*().$" },

        --   -- -- Tweak function call to not detect dot in function name
        --   -- f = gen_spec.function_call({ name_pattern = "[%w_]" }),
        --
        --   -- -- Function definition (needs treesitter queries with these captures)
        --   -- F = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        --
        --   -- -- Make `|` select both edges in non-balanced way
        --   -- ["|"] = gen_spec.pair("|", "|", { type = "non-balanced" }),
      },
    },
    ---   local gen_spec = require('mini.ai').gen_spec
    ---   require('mini.ai').setup({
    ---     custom_textobjects = {
    ---       -- Tweak argument to be recognized only inside `()` between `;`
    ---       a = gen_spec.argument({ brackets = { '%b()' }, separator = ';' }),
    ---
    ---       -- Tweak function call to not detect dot in function name
    ---       f = gen_spec.function_call({ name_pattern = '[%w_]' }),
    ---
    ---       -- Function definition (needs treesitter queries with these captures)
    ---       F = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
    ---
    ---       -- Make `|` select both edges in non-balanced way
    ---       ['|'] = gen_spec.pair('|', '|', { type = 'non-balanced' }),
    ---     }
    ---   })
  },
}
