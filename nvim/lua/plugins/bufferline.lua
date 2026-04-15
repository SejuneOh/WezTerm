return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  config = function()
    vim.opt.showtabline = 2 -- 항상 탭바 표시
    require("bufferline").setup({
      options = {
        mode = "buffers",
        themable = true,
        numbers = "ordinal", -- 탭에 번호 표시
        diagnostics = "nvim_lsp", -- LSP 진단 표시
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
      },
    })

    -- 키 바인딩
    local keymap = vim.keymap.set
    keymap("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "다음 버퍼" })
    keymap("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "이전 버퍼" })
    keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "버퍼 닫기" })
    keymap("n", "<leader>bp", "<cmd>BufferLinePick<cr>", { desc = "버퍼 선택" })

    -- 번호로 바로 이동 (\1, \2, \3 ...)
    for i = 1, 9 do
      keymap("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", { desc = "버퍼 " .. i .. "로 이동" })
    end
  end,
}
