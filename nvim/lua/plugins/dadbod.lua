return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      -- 연결 정보 저장 디렉토리
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/db_ui/tmp"
      vim.g.db_ui_execute_on_save = 0 -- 저장 시 자동 실행 끄기
    end,
    keys = {
      { "<leader>du", "<cmd>DBUIToggle<cr>", desc = "DB UI 토글" },
      { "<leader>df", "<cmd>DBUIFindBuffer<cr>", desc = "DB 쿼리 버퍼 찾기" },
      { "<leader>da", "<cmd>DBUIAddConnection<cr>", desc = "DB 연결 추가" },
    },
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    dependencies = { "tpope/vim-dadbod" },
    config = function()
      -- nvim-cmp에 dadbod 소스 등록 (SQL 파일에서만)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
              { name = "path" },
            },
          })
        end,
      })
    end,
  },
}
