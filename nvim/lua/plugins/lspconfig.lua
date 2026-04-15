return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- LSP 연결 시 키 바인딩 등록
    local on_attach = function(_, bufnr)
      local opts = { buffer = bufnr, silent = true }
      local keymap = vim.keymap.set

      opts.desc = "LSP: 참조 보기"
      keymap("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

      opts.desc = "LSP: 정의로 이동"
      keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

      opts.desc = "LSP: 선언으로 이동"
      keymap("n", "gD", vim.lsp.buf.declaration, opts)

      opts.desc = "LSP: 구현으로 이동"
      keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

      opts.desc = "LSP: 타입 정의로 이동"
      keymap("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

      opts.desc = "LSP: 코드 액션"
      keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

      opts.desc = "LSP: 이름 변경"
      keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)

      opts.desc = "LSP: 버퍼 진단 목록"
      keymap("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

      opts.desc = "LSP: 현재 줄 진단 표시"
      keymap("n", "<leader>d", vim.diagnostic.open_float, opts)

      opts.desc = "LSP: 이전 진단"
      keymap("n", "[d", vim.diagnostic.goto_prev, opts)

      opts.desc = "LSP: 다음 진단"
      keymap("n", "]d", vim.diagnostic.goto_next, opts)

      opts.desc = "LSP: 호버 문서"
      keymap("n", "K", vim.lsp.buf.hover, opts)

      opts.desc = "LSP: 재시작"
      keymap("n", "<leader>rs", ":LspRestart<CR>", opts)
    end

    -- 자동완성 기능을 LSP에 알리기
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- 진단 아이콘 (왼쪽 사이드 표시)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- 각 언어별 LSP 설정
    local servers = { "ts_ls", "pyright", "html", "cssls", "jsonls" }
    for _, server in ipairs(servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end

    -- Lua LSP (Neovim 설정 파일 작성용)
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" }, -- vim 전역 변수 인식
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    -- C# LSP (Omnisharp)
    lspconfig.omnisharp.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = { "omnisharp" },
      enable_roslyn_analyzers = true,
      organize_imports_on_format = true,
      enable_import_completion = true,
    })
  end,
}
