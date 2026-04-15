return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "진단 전체 목록" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "현재 버퍼 진단" },
    { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "심볼 목록 (LSP)" },
    { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP 정의/참조/구현" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location 목록" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix 목록" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODO 목록" },
  },
}
