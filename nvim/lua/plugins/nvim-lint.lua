return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      python = { "pylint" },
    }

    -- 저장 시, 편집 모드 나올 때 린트 실행 (BufEnter는 큰 레포에서 노이즈 → 제외)
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    -- 수동 실행 단축키
    vim.keymap.set("n", "<leader>ml", function()
      lint.try_lint()
    end, { desc = "현재 파일 린트 실행" })
  end,
}
