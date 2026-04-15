return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  config = function()
    local wk = require("which-key")
    wk.setup({})

    -- 단축키 그룹 이름 등록
    wk.add({
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "diagnostic" },
      { "<leader>e", group = "explorer" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>m", group = "misc (format)" },
      { "<leader>r", group = "refactor/rename" },
      { "<leader>s", group = "split" },
      { "<leader>w", group = "window/session" },
    })
  end,
}
