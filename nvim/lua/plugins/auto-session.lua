return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore = false, -- 자동 복원 끄기 (수동으로 제어, v2 키)
      suppressed_dirs = { "~/", "~/Downloads", "/" }, -- v2 키 (구 auto_session_suppress_dirs)
    })

    -- 키 바인딩
    local keymap = vim.keymap.set
    keymap("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "세션 복원" })
    keymap("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "세션 저장" })
  end,
}
