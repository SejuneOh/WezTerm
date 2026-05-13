return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("substitute").setup()

    -- 키 바인딩 (s/S는 Flash에 양보, gs 프리픽스 사용)
    local keymap = vim.keymap.set
    keymap("n", "gs", require("substitute").operator, { desc = "치환 연산자" })
    keymap("n", "gss", require("substitute").line, { desc = "줄 치환" })
    keymap("n", "gS", require("substitute").eol, { desc = "줄 끝까지 치환" })
    keymap("x", "gs", require("substitute").visual, { desc = "선택 영역 치환" })
  end,
}
