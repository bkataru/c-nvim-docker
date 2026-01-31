return {
  { "williamboman/mason.nvim" },
  {
    "williamboman/mason-lspconfig.nvim",
	  dependencies = { "williamboman/mason.nvim" },
    opts = { ensure_installed = { "clangd", "lua_ls" } },
  },
  {
	  "jay-babu/mason-null-ls.nvim",
    dependencies = { "williamboman/mason.nvim" },
	  opts = { ensure_installed = { "clang-format" } },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
	  dependencies = { "williamboman/mason.nvim" },
    opts = { ensure_installed = { "codelldb" } },
  },
}
