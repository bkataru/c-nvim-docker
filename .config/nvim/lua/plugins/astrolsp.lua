return {
  "AstroNvim/astrolsp",
  opts = {
    features = {
      codelens = true,
      inlay_hints = true,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = true,
        allow_filetypes = { "c", "cpp", "h", "hpp" },
      },
      timeout_ms = 1000,
    },
    servers = { "clangd" },
    config = {
      clangd = {
        cmd = {
          "clangd",
          -- "--background-index",
          -- "--clang-tidy",
          -- "--header-insertion=iwyu",
          -- "--completion-style=detailed",
          -- "--function-arg-placeholders",
        },
        capabilities = { offsetEncoding = "utf-8" },
      },
    },
  },
}
