return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- 위 항목 이동
            ["<C-j>"] = actions.move_selection_next, -- 아래 항목 이동
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- 키 바인딩
    local keymap = vim.keymap.set
    keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "파일 찾기" })
    keymap("n", "<leader>fF", function()
      require("telescope.builtin").find_files({
        hidden = true, -- 숨김 파일(dotfile) 포함
        no_ignore = true, -- .gitignore 무시
      })
    end, { desc = "파일 찾기 (숨김 + gitignore 포함)" })
    keymap("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "최근 파일" })
    keymap("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "프로젝트 텍스트 검색" })
    keymap("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "커서 아래 단어 검색" })
    keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "열린 버퍼 목록" })
    keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "도움말 검색" })
  end,
}
