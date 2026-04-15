return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  dependencies = { "hrsh7th/nvim-cmp" },
  config = function()
    require("nvim-autopairs").setup({
      check_ts = true, -- treesitter와 연동
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
      },
    })

    -- nvim-cmp와 연동 (자동완성 후 괄호 자동 닫기)
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp_status, cmp = pcall(require, "cmp")
    if cmp_status then
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end,
}
