return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        -- Buffer navigation
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        -- LSP mappings
        ["<leader>lf"] = { function() vim.lsp.buf.format() end, desc = "Format code" },
        ["<leader>lr"] = { function() vim.lsp.buf.rename() end, desc = "Rename symbol" },
        ["<leader>la"] = { function() vim.lsp.buf.code_action() end, desc = "Code actions" },
        ["<leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Line diagnostics" },
        -- Debugging
        ["<leader>db"] = { function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
        ["<leader>dc"] = { function() require("dap").continue() end, desc = "Start/Continue debugging" },
        ["<leader>dt"] = { function() require("dap").terminate() end, desc = "Terminate debugging" },
        ["<leader>ds"] = { function() require("dap").step_over() end, desc = "Step over" },
        ["<leader>di"] = { function() require("dap").step_into() end, desc = "Step into" },
        ["<leader>do"] = { function() require("dap").step_out() end, desc = "Step out" },
      },
    },
  },
}