return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("substitute").setup()

    -- 키 바인딩
    local keymap = vim.keymap.set
    keymap("n", "s", require("substitute").operator, { desc = "치환 연산자" })
    keymap("n", "ss", require("substitute").line, { desc = "줄 치환" })
    keymap("n", "S", require("substitute").eol, { desc = "줄 끝까지 치환" })
    keymap("x", "s", require("substitute").visual, { desc = "선택 영역 치환" })
  end,
}
