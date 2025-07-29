return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "black" },
      cpp = { "clang-format" },
      javascript = { "clang-format" },
      -- java = { "google-java-format" },
    },
  },
}
