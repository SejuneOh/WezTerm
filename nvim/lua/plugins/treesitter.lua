return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      highlight = { enable = true },
      indent = { enable = true },
      auto_install = true,
      ensure_installed = {
        "lua", "vim", "vimdoc", "javascript", "typescript", "tsx",
        "html", "css", "json", "yaml", "markdown", "markdown_inline",
        "bash", "python", "go", "rust", "c_sharp",
      },
    })
  end,
}
