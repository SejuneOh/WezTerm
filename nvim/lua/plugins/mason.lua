return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      -- roslyn LSP는 커스텀 레지스트리에 있어 추가 필요
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls", -- Lua
        "ts_ls", -- TypeScript / JavaScript
        "pyright", -- Python
        "html",
        "cssls",
        "jsonls",
      },
      automatic_installation = true,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        -- formatters
        "stylua", -- Lua
        "prettier", -- JS / TS / HTML / CSS / JSON / MD
        "csharpier", -- C#
        "black", -- Python
        "isort", -- Python
        -- linters
        "eslint_d", -- JS / TS
        "pylint", -- Python
        -- C# (roslyn.nvim 용)
        "roslyn",
        "netcoredbg",
      },
    })
  end,
}
