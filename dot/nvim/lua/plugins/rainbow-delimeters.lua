local conservative_strategy = function(bufnr)
  -- local current_buffer_name = vim.api.nvim_buf_get_name(bufnr)
  local byte_size = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
  if byte_size >= 1048576 then
    -- Disable in huge files. 1 MiB or more.
    vim.notify("rainbow-delimiters.nvim disabled (" .. tostring(byte_size) .. " Byte)", vim.log.levels.INFO)
    return nil
  else
    -- Did not like the 'local' strategy
    return "rainbow-delimiters.strategy.global"
  end
end

return {
  {
    "hiphish/rainbow-delimiters.nvim",
    -- version = "3277ad5f96eb03c9d618c88e24f683e4364e578c",
    config = function()
      -- This module contains a number of default definitions
      -- require("rainbow-delimiters")

      ---@type rainbow_delimiters.config
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = conservative_strategy,
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          -- TODO: Vim highlight priority. Not sure if we should specify any
          [""] = 110,
          lua = 210,
        },
        -- highlight = {
        --   "RainbowDelimiterRed",
        --   "RainbowDelimiterYellow",
        --   "RainbowDelimiterBlue",
        --   "RainbowDelimiterOrange",
        --   "RainbowDelimiterGreen",
        --   "RainbowDelimiterViolet",
        --   "RainbowDelimiterCyan",
        -- },
        -- blacklist = { "c", "cpp" },
      }
    end,
  },
}
