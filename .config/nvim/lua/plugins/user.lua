return {
  -- DAP for debugging support
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui" },
    config = function()
      local dap = require "dap"
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = "codelldb", args = { "--port", "${port}" } },
      }
      dap.configurations.c = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
      }
    end,
  },
  -- Terminal support
  {
    "akinsho/toggleterm.nvim",
    opts = { open_mapping = [[<C-\>]], direction = "float" },
  },
  -- Enhanced C/C++ syntax highlighting
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "h", "hpp" },
    opts = {
      inlay_hints = { inline = true },
      ast = {
        role_icons = { type = "🄣", declaration = "🄓", expression = "🄔", statement = "🄢" },
      },
    },
  },
  -- Additional formatting options
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { c = { "clang_format" }, cpp = { "clang_format" } } },
  },
}