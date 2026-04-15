return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- 현재 버퍼 단어
    "hrsh7th/cmp-path", -- 파일 경로
    "hrsh7th/cmp-nvim-lsp", -- LSP 연동
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip", -- 스니펫 소스
    "rafamadriz/friendly-snippets", -- 언어별 스니펫
    "onsails/lspkind.nvim", -- 아이콘
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- friendly-snippets 로드
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- 이전 항목
        ["<C-j>"] = cmp.mapping.select_next_item(), -- 다음 항목
        ["<C-b>"] = cmp.mapping.scroll_docs(-4), -- 문서 스크롤 위
        ["<C-f>"] = cmp.mapping.scroll_docs(4), -- 문서 스크롤 아래
        ["<C-Space>"] = cmp.mapping.complete(), -- 수동으로 팝업 열기
        ["<C-e>"] = cmp.mapping.abort(), -- 팝업 닫기
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- 확정
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
