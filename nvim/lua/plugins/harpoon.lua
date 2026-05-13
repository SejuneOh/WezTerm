return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({})

    -- 파일 추가 / 메뉴 토글
    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,
      { desc = "Harpoon: 현재 파일 추가" })
    vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = "Harpoon: 메뉴 토글" })

    -- 슬롯 1~4로 빠른 점프
    vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon: 슬롯 1" })
    vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon: 슬롯 2" })
    vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon: 슬롯 3" })
    vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon: 슬롯 4" })

    -- 이전/다음 슬롯
    vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon: 이전 슬롯" })
    vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon: 다음 슬롯" })
  end,
}
