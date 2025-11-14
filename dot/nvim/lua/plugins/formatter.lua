return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "black" },
      cpp = { "clang-format" },
      javascript = { "clang-format" },
      rust = { "rustfmt", lsp_format = "fallback" },
      -- java = { "google-java-format" },

      -- NOTE: markdown-toc us used by adding the comment <!-- toc -->
      --      verbatim in a markdown file (:normal gcotoc\<esc>).
    },
  },
}
