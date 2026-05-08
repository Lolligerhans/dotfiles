return {
  {
    "brenoprata10/nvim-highlight-colors",
    lazy = false, -- Start applying immediately
    opts = {
      render = "background",

      -- virtual_symbol_prefix = "",
      -- virtual_symbol_suffix = "",
      -- virtual_symbol = "██",

      -- Only works after colon: green or equals = red, not just out of the blue
      -- enable_named_colors = true, -- Does not highlight green

      -- bg-blue-500
      -- enable_tailwind = true,
    },
    keys = {
      {

        -- Would choose <leader>uc (UI color) but LazyVim uses it. For now I just
        -- place it somewhere conflict free.
        -- Show colors like #ff8800 or green
        "<leader>ußc",
        function()
          require("nvim-highlight-colors").toggle()
        end,
        mode = "n",
        remap = false,
        desc = "nvim-highlight-colors toggle",
      },
    },
  },
}
